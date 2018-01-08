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
  # 1.最小と開始の比率がN%以上ある
  # 2.最小と終了の比率がN%以上ある
  # 3.終了が1つ前より上昇している
  def self.buy?(c_type)
    averages = self.where(currency_pair: "#{c_type}_jpy").order(:timestamp).pluck(:price)

    results = {}


    #1
    rate = TradeSetting.where(trade_type: :buy_rate_of_up).first.value
    first_diff = averages.first / averages.min
    results["first~min"] =  (rate < first_diff)

    #2
    last_diff = averages.last / averages.min
    results["last~min"] =  (rate < last_diff)

    #3
    if 2 <= averages.count
      recents = averages.last(2)
      results["recent up"] = (recents.first < recents.last)
    else
      results["recent up"] = false
    end

    results
  end
end
