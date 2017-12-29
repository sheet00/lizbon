require 'thwait'
# zaif価格取得クラス
class GetPrice
  def initialize()
    @api = Zaif_Extend.new(
      api_key: Rails.application.secrets.zaif_key,
      api_secret: Rails.application.secrets.zaif_secret,
      cool_down: true,
      cool_down_time: 10
    )
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


  def execute
    #量が多いため、ログ出力なし
    log_level = Rails.logger.level
    Rails.logger.level = Logger::INFO


    #価格取得
    get_last_price

    #取得データを元に移動平均データ生成
    CurrencyAverage.create_average

    Rails.logger.level = log_level
  end


  private
  #板から価格一覧取得
  def get_last_price
    ApplicationController.helpers.log("[get_last_price][start]")

    #マルチスレッドで取得
    all_trades = th_get_all_trades



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


    #古いログデータ削除
    CurrencyHistory.delete_before_log
    ApplicationController.helpers.log("[get_last_price][end]")
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



end
