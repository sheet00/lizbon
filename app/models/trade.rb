require 'thwait'

#取引管理クラス
class Trade
  class ZaifCancelErrorException < StandardError; end

  def initialize()
    @api = Zaif_Extend.new(
      api_key: Rails.application.secrets.zaif_key,
      api_secret: Rails.application.secrets.zaif_secret,
      cool_down: true,
      cool_down_time: 10
    )

    #テストの場合はAPI未実行
    @is_test = false
  end

  #例外処理 戻り値はブロック実行結果
  def retry_on_error(times: 5)
    try = 0

    begin
      try += 1
      result = yield
    rescue => e
      ap e
      pp "retry:" + try.to_s
      sleep 3

      retry if try < times
      raise
    end

    return result
  end



  # 取引実行
  def execute
    #価格取得
    get_last_price

    #同期実行
    #購入判定前に同期することで、二重売買を防ぐ
    #成約時の財布増減もこの時点で対応
    sync_zaif

    #一回辺りの購入額計算
    #処理ごと通貨ステータスが切り替わるため、ループ前に用意
    buy_money = get_once_buy_money

    #通貨ごとトレード
    Target.all.each{|t|
      #トランザクションは通貨処理単位
      ActiveRecord::Base.transaction do

        c_type = t.currency_type

        #取引判定
        trade_type = trade_type(c_type)

        #取引
        case trade_type
        when "bid","ask" then
          result = trade(trade_type, c_type, buy_money: buy_money)

        when "wait" then
          #キャンセル判定
          if do_cancel?(c_type)
            result = auto_cancel(c_type)
          else
            result = "wait"
          end

        else
          result = trade_type
        end

        #bot実行ログ
        Bot.create(trade_type: result, currency_type: c_type)
      end
    }
  end


  #　未約定一覧から該当注文をキャンセルする
  #　時間短縮のため、存在しないオーダーを指定した場合はそのまま例外
  # キャンセル実行時、サーバー上でキャンセルされていなかったときの対応
  # オーダーが残っているため、次回実行時、再度キャンセル処理が実行される(確実にキャンセルされるまでループ)
  def order_cancel(order_id)
    order = ActiveOrder.where(order_id: order_id).first
    ActiveRecord::Base.transaction do
      result = retry_on_error do
        #キャンセル時、ペア指定必須(トークンの場合指定必須のため)
        @api.cancel(order_id, order.currency_pair)
      end

      ActiveOrder.where(order_id: order_id).delete_all

      ApplicationController.helpers.log("[active_order][cancel][api result]",result)
    end
  end



  #zaifから
  #取引履歴データ
  #未成約データ
  #を同期する
  def sync_zaif
    sync_trade_history
    sync_active_order
  end


  #対象通貨の移動平均算出
  def get_average_list(c_type)
    #マスタ値分、遡ってデータを移動平均を算出
    average_list_min = TradeSetting.where(trade_type: "average_list_min").first.value.to_i
    from_date = Time.now - average_list_min.minute

    history = CurrencyHistory.where(
      "currency_pair = ? and ? < timestamp",
      "#{c_type}_jpy",
      from_date.to_i
    ).order(:timestamp)

    #履歴なし、少ない場合は空応答
    return [] if not history.any? or history.count < 100

    price_list = history.pluck(:price)

    #移動平均カウント
    count = (history.count * 0.9).round

    ave_list = []
    price_list.each_cons(count).each{|p|
      move_average = p.inject(:+) / count.to_f
      ave_list << move_average
    }

    return ave_list
  end



  #------------------------------------------
  private

  #　今回実行時に1通貨で利用可能な金額の判定
  def get_once_buy_money
    results = []
    Target.all.each{|t|
      results << trade_type(t.currency_type)
    }

    #waitかつaskでないもの=bid or 相場待ち
    count = results.select{|a| a != "wait" and a != "ask"}.count
    return 0 if count <= 0

    #実財布ではなく、買い注文中の金額は除外して計算
    #お財布100円
    #先注文A100円
    #実財布には100円残っているので再度注文B100円
    #注文AとBが成立が成立した場合、-200円になってしまう
    ex_wallet = Wallet.exclude_order.select{|w| w.currency_type == "jpy"}.first
    buy_money = ex_wallet.money / count
    return buy_money.floor
  end


  #板から価格一覧取得
  def get_last_price
    ApplicationController.helpers.log("[get_last_price][start]")

    #マルチスレッドで取得
    all_trades = th_get_all_trades


    #量が多いため、ログ出力なし
    log_level = Rails.logger.level
    Rails.logger.level = Logger::INFO

    Target.all.each{|t|
      h_max_timestamp = CurrencyHistory.where(currency_pair: "#{t.currency_type}_jpy").maximum(:timestamp)
      recent_timestamp = h_max_timestamp.present? ? h_max_timestamp.to_i : (Time.now - 1.days).to_i

      #テーブルに含まれていないデータ全て取得
      new_trades = all_trades.select{|t| recent_timestamp < t["date"]}

      new_trades.each{|t|
        CurrencyHistory.create([
                                 currency_pair: t["currency_pair"],
                                 trade_type: t["trade_type"],
                                 price: t["price"],
                                 amount: t["amount"],
                                 timestamp: t["date"]
        ])
      }
    }

    Rails.logger.level = log_level

    #古いログデータ削除
    CurrencyHistory.delete_before_day
    ApplicationController.helpers.log("[get_last_price][end]")
  end


  #売る、買う判定
  # 財布：未約定
  # ×：×　買い注文を実行
  # ○：×　売り注文を実行
  # ×：○　売り、買いの成約待ち
  # ○：○　成約待ち中に、手動でお財布に入れたとき>>売り、買いの成約待ち
  # c_type:通貨コード
  def trade_type(c_type)
    pair = c_type + "_jpy"
    has_order = ActiveOrder.where(:currency_pair =>pair).any?

    # 待ち
    # 財布：未約定
    # ×：○　売り、買いの成約待ち
    # ○：○　成約待ち中に、手動でお財布に入れたとき>>売り、買いの成約待ち
    # 未約定がある段階で必ず待ち
    return "wait" if has_order


    # 最小単位以下であれば購入金額なし、とみなす>>買い注文へ
    unit_min = CurrencyPair.where(currency_pair: pair).first.unit_min
    has_wallet = Wallet.where("currency_type = ? and ? <= money", c_type, unit_min).any?


    # 買い
    # 財布：未約定
    # ×：×　買い注文を実行
    if not has_wallet and not has_order then
      #相場確認
      ave_list = get_average_list(c_type)
      return "最新データ取得待ち" unless ave_list.any?


      #テスト実行時は相場を見ない
      return "bid" if @is_test


      #移動平均が上がっているなら買う
      if ave_list.first < ave_list.last
        return "bid"
      else
        return "相場安定待ち"
      end

    end

    #売り
    # 財布：未約定
    # ○：×　売り注文を実行
    if has_wallet and not has_order then
      return "ask"
    end
  end



  #売買実行
  #trade_type bid or ask or ask
  #c_type　通貨
  #options
  #buy_money 1回辺りの購入金額
  def trade(trade_type,c_type, buy_money: nil)

    #bid
    if trade_type == "bid"
      #金額>>最新取引価格を参考
      price =  get_buy_price(c_type)

      #量>>おこずかいの中で、買えるだけ
      amount = get_buy_amount(c_type,buy_money,price)

      #0の場合は何もしない
      return "購入額不足" if amount <= 0.0


      #ask
    else
      #買った額からN% or losscut時は即売り
      price = get_sell_price(c_type,"upper")
      lower_limit =  get_sell_price(c_type,"lower")

      #買った分全て
      amount = get_sell_amount(c_type)

      #0の場合は何もしない
      return "売却額不足" if amount <= 0.0
    end


    #transaction_id生成
    transaction_id = SecureRandom.hex(8)



    #テスト実行
    if @is_test
      result =
      if trade_type == "bid"
        test_trade(transaction_id)
      else
        test_trade(transaction_id)
      end
      ApplicationController.helpers.log("テスト実行","テスト実行")
    else
      #売買トレードはリトライしない
      #API上エラーで返っても、API上通ってる可能性があるため
      result =
      if trade_type == "bid"
        @api.bid(c_type,price,amount,"jpy",transaction_id)
      else
        @api.ask(c_type,price,amount,"jpy",transaction_id)
      end
    end




    #即時成立、未成立にかかわらず、必ず未約定オーダーに保存する
    #約定金額
    contract_price = (price * amount).round(4)

    active_order = ActiveOrder.new(
      order_id: result["order_id"],
      currency_pair: c_type + "_jpy",
      action: trade_type,
      amount: amount.to_s,
      price: price.to_s,
      timestamp: Time.now.to_i,
      transaction_id: transaction_id,
      limit: nil,
      lower_limit: lower_limit,
      contract_price: contract_price,
    )

    active_order.save
    ApplicationController.helpers.log("[trade][#{trade_type}][#{c_type}][api result]",result)

    return trade_type
  end



  # 成約待ち時、キャンセルするかしないか判定
  # キャンセル条件
  # 買い：買い注文をだしてN分買いが確定しない
  # 売り：損切りポイントに達した
  def do_cancel?(c_type)
    order = ActiveOrder.where(currency_pair: "#{c_type}_jpy").first

    #データなし
    return false unless order.present?

    #キャンセル買い直し
    if order.action == "bid"
      buy_date = Time.at(order.timestamp.to_i)
      return buy_date < DateTime.now - 5.minute
    end


    #キャンセル損切り
    if order.action == "ask"

      #損切り売り中の場合はwait処理
      return false if Wallet.where(currency_type: c_type).first.is_losscut

      #ロスカット判定
      #最新単価がロスカット下限以下の場合、auto_cancel実行
      #>>売りキャンセル=ロスカットフラグON
      #>>次回実行時、ロスカットフラグで売りなら即売却
      history = CurrencyHistory.where(currency_pair: "#{c_type}_jpy").order("timestamp desc").first
      return history.price < order.lower_limit
    end
  end


  #対象通貨のオーダーをキャンセルし、後続処理
  def auto_cancel(c_type)
    order = ActiveOrder.where(currency_pair: "#{c_type}_jpy").first

    #キャンセル
    order_cancel(order.order_id)


    #買いキャンセルは次回購入へ
    if order.action == "bid"
      return "キャンセル：買い注文時間経過"
    end

    #売りキャンセル処理
    if order.action == "ask"
      #los_catフラグ設定
      wallet = Wallet.where(currency_type: c_type).first
      wallet.is_losscut = true
      wallet.save

      return "キャンセル：ロスカット"
    end
  end


  #購入単価取得
  def get_buy_price(c_type)
    #直近の平均値を取得
    price = get_average_list(c_type).last

    #マスタから掛け率を取得してpriceを設定する
    per = TradeSetting.where(trade_type: :buy).first.value
    price = price * per

    return round_price(c_type,price)
  end


  #購入数量算出
  #おこずかい / 買う金額 = 購入数量
  #購入最小単位で丸める
  def get_buy_amount(c_type,use_price,price)
    #use_priceは整数の場合もあるため、小数後、計算する
    amount = (use_price * 1.0) / price
    return floor_amount(c_type,amount)
  end


  #売価取得
  #trade_type: 上限upper or 下限lower
  #losscut設定時は、即売り金額
  def get_sell_price(c_type,trade_type = "upper")
    #1.直近の購入
    buy_timestamp = (Time.now - 10.minute).to_i
    trade = TradeHistory.where("currency_pair = ? and ? < timestamp","#{c_type}_jpy", buy_timestamp).order("timestamp desc").first

    #2.直前の相場金額
    history = CurrencyHistory.where(currency_pair: "#{c_type}_jpy").order("timestamp desc").first
    #価格履歴もない場合は取得する
    unless history.present?
      get_last_price
      history = CurrencyHistory.where(currency_pair: "#{c_type}_jpy").order("timestamp desc").first
    end

    per = TradeSetting.where(trade_type: "sell_#{trade_type}").first.value

    #直近購入があれば、直近の購入額 * N%
    #直近購入なければ、相場価格から * N%
    price =
    if trade.present?
      trade.price * per
    else
      history.price * per
    end


    #losscut金額設定 6掛で即売り
    if Wallet.where(currency_type: c_type).first.is_losscut
      if trade_type == "upper"
        price = history.price * 0.6
      else
        price = history.price
      end
    end

    return round_price(c_type,price)
  end

  #数量取得
  #財布の中全て
  def get_sell_amount(c_type)
    amount = Wallet.where(currency_type: c_type).first.money

    return floor_amount(c_type,amount)
  end


  #金額丸め
  def round_price(c_type,val)

    #小数点丸め
    pair = CurrencyPair.where(currency_pair: "#{c_type}_jpy").first
    digest = pair.currency_digest

    val = val.round(digest)

    #整数の場合は0削除
    #整数のdigestはマイナス
    if digest <= 0
      val = val.to_i
    end

    return val
  end


  #数量丸め
  def floor_amount(c_type,val)

    pair = CurrencyPair.where(currency_pair: "#{c_type}_jpy").first
    digest = pair.unit_digest

    val = val.floor(digest)

    #整数の場合は0削除
    #整数のdigestはマイナス
    if digest <= 0
      val = val.to_i
    end

    return val
  end



  #取引履歴一覧を同期する
  #買い成約
  #購入JPYを引き落とし
  #Walletに購入コインを追加
  #売り成約
  #WalletにJPY追加
  #売却コインを引き落とし
  def sync_trade_history
    ApplicationController.helpers.log("[sync_trade_history][start]")

    #今回取得できた取引成立レコード
    #bot取引のみ
    trades = th_get_trade_history

    trades.each{|t|

      data = t[1]
      order_id = t[0]
      transaction_id = data["comment"]
      currency_pair = data["currency_pair"]
      action = data["action"]
      amount = data["amount"]
      price = data["price"]
      #feeの設定がない通貨ある
      fee = data["fee"].presence || 0
      fee_amount = data["fee_amount"]
      contract_price = (amount * price).round(4)
      your_action = data["your_action"]
      timestamp = data["timestamp"]

      #該当IDのデータがあれば次処理
      #複数回買いが成立するケース
      #同一transactionIDで複数回成立するケースもある
      #100売り>>60買い>>40買い：合計100
      #一意のorder_idで取引履歴を記録すること
      next if TradeHistory.where(order_id: order_id).any?

      ActiveRecord::Base.transaction do

        #取引履歴記録
        t_history = TradeHistory.create(
          order_id: order_id,
          currency_pair: currency_pair,
          action: action,
          amount: amount,
          price: price,
          fee: fee,
          fee_amount: fee_amount,
          contract_price: contract_price,
          your_action: your_action,
          timestamp: timestamp,
          transaction_id: transaction_id
        )


        #お財布追加
        #未成約一覧は別同期しているので、ここでは管理しない
        c_type = currency_pair.gsub("_jpy","")


        #買い成約
        #購入JPYを引き落とし
        #Walletに購入コインを追加
        #fee
        #買ったとき：対象通貨の数量がひかれる

        trade_time = Time.at(timestamp.to_i)

        if your_action == "bid"
          #jpy引き落とし
          Wallet.add_wallet("jpy", -1.0 * contract_price, trade_time)
          #c_type追加
          Wallet.add_wallet(c_type, amount - fee_amount, trade_time)


          #売り成約
          #WalletにJPY追加
          #売却コインを引き落とし
          #fee
          #売ったとき：JPYからひかれる
        else
          #jpy追加
          Wallet.add_wallet("jpy", contract_price - fee_amount, trade_time)
          #c_type引き落とし
          Wallet.add_wallet(c_type, -1.0 * amount, trade_time)

          #差益記録
          #最新の購入単価を元に、売買差益を計算
          Capital.cal_trade_capital(order_id)

          #losscut成立の場合は、フラグ解除
          wallet = Wallet.where(currency_type: c_type).first
          if wallet.present? and wallet.is_losscut
            wallet.is_losscut = false
            wallet.save
          end
        end

        result = your_action == "bid" ? "買い確定" : "売り確定"
        Bot.create(trade_type: result, currency_type: c_type)
      end
      #transaction end


      if trades.present?
        ApplicationController.helpers.log("[sync_trade_history][api result]", t)
      end

    } #trade.each
  end


  #　Zaifサーバーの未成約一覧を同期する
  #　zaif:local
  #　×:×　両方なし：何もしない
  #　×:○　ローカルのみある：Delete
  #　○:×　ザイフのみある：Insert
  #　○:○　両方ある：何もしない
  def sync_active_order
    ApplicationController.helpers.log("[sync_active_order][start]")

    all_th = []
    zaif_orders = []

    Target.all.each_with_index{|t,i|
      all_th << Thread.new{
        orders = retry_on_error do
          # マルチスレッドの場合、一斉にAPIアクセスされるため、スレッドごとn秒間隔で実行
          sleep i
          @api.get_active_orders({currency_pair: t.currency_type + "_jpy" })
        end

        # 未約定にない通貨を指定したとき、{}が応答する
        orders.each{|o|
          # botデータのみ対象
          zaif_orders << o if o[1]["comment"] != ""
        }

      }
    }

    ThreadsWait.all_waits(*all_th) {|th|
      pp("[sync_active_order][thread end]", th.inspect)
    }


    ActiveRecord::Base.transaction do
      #　×:○　ローカルのみある：Delete
      #　ケースとしては、キャンセルされているのに、ローカルで残っているor未成約が成約済になっている
      #　同一TransactionID、複数回購入のケースもあるので、order_idでひくこと
      ActiveOrder.all.each{|order|
        #json取得時なので、to_sでひくこと
        has_zaif_order = zaif_orders.any? {|z| z[0] == order.order_id.to_s}

        #zaif側にない=ローカルのみあるのであれば、データ削除
        unless has_zaif_order
          ActiveOrder.where(order_id: order.order_id).delete_all
        end
      }


      #　○:×　ザイフのみある：Insert
      zaif_orders.each{|z|
        order_id = z[0]
        data = z[1]

        currency_pair = data["currency_pair"]
        action = data["action"]
        amount = data["amount"]
        price = data["price"]
        timestamp = data["timestamp"]
        transaction_id = data["comment"]

        if not ActiveOrder.where(order_id: order_id).any?
          #売りの場合、損切り価格を再設定
          if action == "ask"
            c_type = currency_pair.gsub("_jpy","")
            lower_limit = get_sell_price(c_type,"lower")
          end

          ActiveOrder.create(
            [
              order_id: order_id,
              currency_pair: currency_pair,
              action: action,
              amount: amount,
              price: price,
              timestamp: timestamp,
              transaction_id: transaction_id,
              limit: nil,
              contract_price: (amount * price).round(4),
              lower_limit: lower_limit
            ]
          )
        end
      }



    end

    if zaif_orders.present?
      ApplicationController.helpers.log("[sync_active_order][api result]",zaif_orders)
    end
  end


  # マルチスレッドで全通貨価格取得
  def th_get_all_trades

    all_trades = []
    all_th = []
    Target.all.each {|t|
      all_th << Thread.new {
        trades =
        retry_on_error do
          @api.get_trades(t.currency_type)
        end

        all_trades.concat(trades)
      }
    }

    ThreadsWait.all_waits(*all_th) {|th|
      pp("[th_get_all_trades][thread end]", th.inspect)
    }

    return all_trades
  end


  #取引履歴を取得する
  #return 取引成約データ
  def th_get_trade_history
    #トレード成約は毎分10以下を想定

    #取得数
    count = 10
    trades = {}
    all_th = []


    #通貨指定なしの場合、下記のみ取得
    #btc_jpy/mona_jpy/xem_jpy/xem_btc/mona_btc/
    all_th << Thread.new {
      t = retry_on_error do
        @api.get_my_trades({count: count})
      end

      trades.update(t)
    }

    sleep 1


    # #上記外のトレード取得
    other_c_type = Target.where.not(currency_type: ["btc","mona","xem"]).pluck(:currency_type)
    other_c_type.each_with_index{|c,i|

      all_th << Thread.new {
        t = retry_on_error do
          # マルチスレッドの場合、一斉にAPIアクセスされるため、スレッドごとn秒間隔で実行
          sleep i
          @api.get_my_trades({count: count, currency_pair: "#{c}_jpy"})
        end
        trades.update(t)
      }
    }

    ThreadsWait.all_waits(*all_th) {|th|
      pp("[th_get_trade_history][thread end]", th.inspect)
    }

    #コメントデータがないものは人間発注なので対象外
    trades.select! {|k,v| v["comment"] != ""}

    #入金履歴は取引時間が古い～新しいで記録される必要があるため、ソート必須
    #第一キーdatetime, 第二キーorder_id
    trades = trades.to_a.sort_by {|a|
      [a[1]["datetime"], a[0]]
    }

    return trades
  end


  #tradeテストデータ返却
  def test_trade(transaction_id)
    h = {
      "success" => 1,
      "return" => {
        "received"=>0.0,
        "remains"=>33.0,
        "order_id"=> rand(10000000..99999999),
        "comment"=> transaction_id,
        "funds"=>
        {"jpy"=>4046.28741,
         "btc"=>0.0358,
         "xem"=>100.9999,
         "mona"=>0.0,
         "BCH"=>0.10007}
      }
    }

    h["return"]
  end
end
