class CurrencyAverage < ApplicationRecord

  # currency_historyから移動平均を生成する
  def self.create_average
    ApplicationController.helpers.log("[create_average][start]")
    ActiveRecord::Base.transaction do
      CurrencyAverage.delete_all

      Target.all.each{|t|
        ave_list = get_average_list(t.currency_type)
        ave_list.each{|r|
          CurrencyAverage.create(currency_pair: "#{t.currency_type}_jpy", price: r.round(4))
        }
      }

    end
    ApplicationController.helpers.log("[create_average][end]")
  end



  #対象通貨の移動平均算出
  def self.get_average_list(c_type)
    #マスタ値分、遡ってデータを移動平均を算出
    average_list_min = TradeSetting.where(trade_type: "average_list_min").first.value.to_i
    from_date = Time.now - average_list_min.minute

    history = CurrencyHistory.where(
      "currency_pair = ? and ? < timestamp",
      "#{c_type}_jpy",
      from_date.to_i
    ).order(:timestamp)

    #履歴なし、少ない場合は空応答
    return [] if not history.present? or history.count < 30

    price_list = history.pluck(:price)

    #x万件以上ある場合、処理速度アップのため、N件単位で平均算出する
    #n=2　2件に1つ採用 n=3 3件に1つ採用
    #btcで1時間1万程度
    n = 2
    if 20000 < price_list.count
      result = []
      price_list.each_with_index{|val,i|
        #余剰が0なら計算対象
        result << val if i % n == 0
      }

      price_list = result
      ApplicationController.helpers.log("[create_average][1/#{n}]")
    end


    #移動平均カウント　n個分計算
    count = (price_list.count - 19).round

    ave_list = []
    price_list.each_cons(count).each{|p|
      move_average = p.inject(:+) / count.to_f
      ave_list << move_average
    }

    return ave_list
  end

end
