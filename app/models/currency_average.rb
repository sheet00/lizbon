class CurrencyAverage < ApplicationRecord

  # currency_historyから平均を生成する
  def self.create_average
    ApplicationController.helpers.log("[create_average][start]")
    ActiveRecord::Base.transaction do
      CurrencyAverage.delete_all

      CurrencyHistory.group_by_hour.each{|r|
        CurrencyAverage.create(
          currency_pair: r.currency_pair,
          price: r.price,
          timestamp: r.timestamp
        )
      }
    end
    ApplicationController.helpers.log("[create_average][end]")
  end


  # 指定通貨の上昇率を取得する
  # データなしの場合nil
  def self.get_rate_of_up(c_pair)
    averages = CurrencyAverage.where(currency_pair: c_pair).order(:timestamp).pluck(:price)
    if averages.present?
      return (averages.last / averages.first).round(5)
    else
      return nil
    end
  end

  # 指定通貨の購入判定結果
  # 条件
  # 1.開始<終了
  # 2.最小<開始
  # 3.終了=最大
  # 4.最小と終了の比率がN%以上ある
  def self.buy?(c_type)
    averages = self.where(currency_pair: "#{c_type}_jpy").order(:timestamp).pluck(:price)

    results = {}

    #1
    results["first < last"] = (averages.first < averages.last)

    #2
    results["min < first"] =  (averages.min < averages.first)

    #3
    results["last = max"] =  (averages.max == averages.last)

    #4
    rate = TradeSetting.where(trade_type: :buy_rate_of_up).first.value
    last_diff = averages.last / averages.min
    results["rate of up"] =  (rate < last_diff)


    results
  end
end
