#取引管理クラス
class Trade
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
      return e.message if e.message == "order not found"

      pp "retry:" + try.to_s
      sleep 2

      retry if try < times
      raise
    end

    return result
  end



  #取引実行
  def execute
    #1.取引履歴一覧更新
    #2.買い成約：Walletに購入コインを追加　売り成約：WalletにJPY追加
    #3.未成約一覧削除
    ActiveRecord::Base.transaction do
      #今回取得できた取引成立レコード
      trades = get_trade_history

      #対象通貨が未成約から成約になったので、お財布に追加
      #過去データがある場合、未成約なしで取引結果を取得する可能性があるので、未成約分として設定されていた取引のみを対象とすること
      trades.each{|t|
        if ActiveOrder.where(transaction_id: t.transaction_id).any?
          c_type = t.currency_pair.gsub(/_jpy/,"")


          #買い>>購入した通貨(量)をお財布に入れる
          #売り>>売ったJPYをお財布に入れる
          #fee
          #買ったとき：対象通貨の数量がひかれる
          #売ったとき：JPYからひかれる
          if t.your_action == "bid"
            Wallet.add_wallet(c_type, t.amount - t.fee_amount)
          else
            Wallet.add_wallet("jpy", t.contract_price - t.fee_amount)

            #loscat成立の場合は、フラグ解除
            wallet = Wallet.where(currency_type: c_type).first
            if wallet.present? and wallet.is_loscat
              wallet.is_loscat = false
              wallet.save
            end
          end

          result = t.your_action == "bid" ? "買い確定" : "売り確定"
          Bot.create(trade_type: result,currency_type: c_type)
        end
      }

      #取引成立分の未成約一覧削除
      ActiveOrder.delete_close_order
    end

    #4.価格取得
    ActiveRecord::Base.transaction do
      Target.all.each{|t|
        get_last_price(t.currency_type)
      }
    end

    #一回辺りの購入額計算
    #処理ごと通貨ステータスが切り替わるため、ループ前に用意
    buy_money = get_once_buy_money


    #5.通貨ごとトレード
    Target.all.each{|t|
      #トランザクションは通貨処理単位
      ActiveRecord::Base.transaction do

        c_type = t.currency_type

        #2.取引判定
        trade_type = trade_type(c_type)

        #3.取引
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
        Bot.create(trade_type: result,currency_type: c_type)

      end
    }

  end


  #未約定一覧から該当注文をキャンセルする
  #財布にもお金を戻す
  def order_cancel(order_id)
    ActiveRecord::Base.transaction do

      #APIキャンセル
      result = retry_on_error do
        @api.cancel(order_id)
      end

      #財布に戻す
      order = ActiveOrder.where(order_id: order_id).first

      #別プロセスで消されていた場合を考慮し、未約定一覧にデータがあるときのみ、財布に戻す
      return unless order.present?

      #bid jpyを戻す
      if order.action == "bid"
        #ask 通貨を戻す
        Wallet.add_wallet("jpy", order.contract_price)
      else
        #ask 通貨を戻す
        Wallet.add_wallet(order.currency_pair.gsub("_jpy",""),order.amount)
      end

      #データ削除
      ActiveOrder.where(order_id: order_id).delete_all

      ApplicationController.helpers.log("[active_order][cancel][api result]",result)

    end
  end



  #------------------------------------------
  private

  #今回実行時に1通貨で利用可能な金額の判定
  #全通貨のtrade_typeをカウントし計算
  def get_once_buy_money
    count = 0
    Target.all.each{|t|
      count += 1  if trade_type(t.currency_type) == "bid"
    }

    return 0 if count == 0

    buy_money = Wallet.where(currency_type: :jpy).first.money / count
    return buy_money.floor
  end


  #板から価格一覧取得
  #c_type:通貨コード
  def get_last_price(c_type)
    h_max_timestamp = CurrencyHistory.where(currency_pair: "#{c_type}_jpy").maximum(:timestamp)
    recent_timestamp = h_max_timestamp.present? ? h_max_timestamp.to_i : (Time.now - 1.days).to_i

    trades =
    retry_on_error do
      @api.get_trades(c_type)
    end

    #テーブルに含まれていないデータ全て取得
    new_trades = trades.select{|t| recent_timestamp < t["date"]}
    new_trades.each{|t|
      CurrencyHistory.create([
                               currency_pair: t["currency_pair"],
                               trade_type: t["trade_type"],
                               price: t["price"],
                               amount: t["amount"],
                               timestamp: t["date"]
      ])
    }
  end


  #売る、買う判定
  # 財布：未約定
  # ×：×　買い注文を実行
  # ○：×　売り注文を実行
  # ×：○　売り、買いの成約待ち
  # ○：○　成約待ち中に、手動でお財布に入れたとき>>売り、買いの成約待ち
  #c_type:通貨コード
  def trade_type(c_type)
    pair = c_type + "_jpy"
    has_order = ActiveOrder.where(:currency_pair =>pair).any?

    #待ち
    # 財布：未約定
    # ×：○　売り、買いの成約待ち
    # ○：○　成約待ち中に、手動でお財布に入れたとき>>売り、買いの成約待ち
    #未約定がある段階で必ず待ち
    return "wait" if has_order


    #最小単位以下であれば購入金額なし、とみなす>>買い注文へ
    unit_min = CurrencyPair.where(currency_pair: pair).first.unit_min
    has_wallet = Wallet.where("currency_type = ? and ? <= money", c_type, unit_min).any?

    #買い
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
      #買った額からN% or loscut時は即売り
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
      result =
      if trade_type == "bid"
        retry_on_error do
          @api.bid(c_type,price,amount,"jpy",transaction_id)
        end
      else
        retry_on_error do
          @api.ask(c_type,price,amount,"jpy",transaction_id)
        end
      end
    end







    #即時成立、未成立にかかわらず、必ず未約定オーダーに保存する
    #後処理で入金処理する際、未約定に含まれているか？を確認するため

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

    ApplicationController.helpers.log("[active_order][#{trade_type}][#{c_type}][api result]",result)
    ApplicationController.helpers.log("[active_order][#{trade_type}][#{c_type}][AR]",active_order)




    #お財布処理
    if trade_type == "bid"
      wallet_currency = "jpy"
      money = contract_price
    else
      wallet_currency = c_type
      money = amount
    end

    #購入キューを入れた段階で、お財布から購入マイナス
    Wallet.add_wallet(wallet_currency, -1 * money)


    return trade_type
  end




  #成約待ち時、キャンセルするかしないか判定
  #キャンセル条件
  #買い：買い注文をだしてN分買いが確定しない
  #売り：損切りポイントに達した
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
      return false if Wallet.where(currency_type: c_type).first.is_loscat

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
      wallet.is_loscat = true
      wallet.save

      return "キャンセル：ロスカット"
    end
  end


  #取引履歴を取得する
  #return 取引成約データ
  def get_trade_history

    #トレード成約は毎分10以下を想定
    trades = retry_on_error do
      @api.get_my_trades({count: 10})
    end

    #成約一覧
    result = []

    trades.each{|t|

      data = t[1]
      comment = data["comment"]
      transaction_id = comment

      #コメントデータがないものは人間発注なので対象外
      next if comment == ""

      #取引履歴記録
      #該当IDのデータがなければ、Insert
      unless TradeHistory.where(transaction_id: comment).any? then

        order_id = t[0]
        currency_pair = data["currency_pair"]
        action = data["action"]
        amount = data["amount"]
        price = data["price"]
        fee = data["fee"]
        fee_amount = data["fee_amount"]
        contract_price = (amount * price).round(4)
        your_action = data["your_action"]
        timestamp = data["timestamp"]

        t_history = TradeHistory.create(
          {
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
          }
        )

        result << t_history
      end
    }

    if result.present?
      ApplicationController.helpers.log("[trade_history]",result)
    end

    return result
  end


  #購入単価取得
  def get_buy_price(c_type)
    #直近の平均値を取得
    price = get_average_list(c_type).last

    #マスタから掛け率を取得してpriceを設定する
    per = TradeSetting.where(trade_type: :buy).first.percent
    price = price * per

    return round_price(c_type,price)
  end



  #購入数量算出
  #おこずかい / 買う金額 = 購入数量
  #購入最小単位で丸める
  def get_buy_amount(c_type,use_price,price)
    #use_priceは整数の場合もあるため、小数後、計算する
    amount = (use_price * 1.0) / price

    pair = CurrencyPair.where(:currency_pair => c_type + "_jpy")[0]
    digest = pair.unit_digest

    return floor_amount(c_type,amount)
  end


  #売価取得
  #trade_type: 上限upper or 下限lower
  #loscut設定時は、即売り金額
  def get_sell_price(c_type,trade_type = "upper")
    #1.直近の購入
    buy_timestamp = (Time.now - 10.minute).to_i
    trade = TradeHistory.where("currency_pair = ? and ? < timestamp","#{c_type}_jpy", buy_timestamp).order("timestamp desc").first

    #2.直前の相場金額
    history = CurrencyHistory.where(currency_pair: "#{c_type}_jpy").order("timestamp desc").first
    per = TradeSetting.where(trade_type: "sell_#{trade_type}").first.percent

    #直近購入があれば、直近の購入額 * N%
    #直近購入なければ、相場価格から * N%
    if trade.present?
      price = trade.price * per
    else
      price = history.price * per
    end


    #loscut金額設定 6掛で即売り
    if Wallet.where(currency_type: c_type).first.is_loscat
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


  #未成約注文一覧
  def get_active_order
    pp @api.get_active_orders
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


  #対象通貨の移動平均算出
  def get_average_list(c_type)
    history = CurrencyHistory.where(
      "currency_pair = ? and ? < timestamp", "#{c_type}_jpy", (Time.now - 10.minute).to_i
    ).order(:timestamp)

    #履歴なし、少ない場合は空応答
    return [] if not history.any? or history.count < 10

    price_list = history.pluck(:price)

    #移動平均カウント
    count = (history.count / 10).round

    ave_list = []
    price_list.each_cons(count).each{|p|
      move_average = p.inject(:+) / count.to_f
      ave_list << move_average
    }

    return ave_list
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
