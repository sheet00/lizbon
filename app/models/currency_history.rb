class CurrencyHistory < ApplicationRecord

  # 実行日からn時間前のログ削除
  def self.delete_before_log
    #売り下限時間、移動平均確認時間、両者のうち、長いほうに合わせて削除する
    average_time = TradeSetting
    .where(trade_type: :sell_lower_hour)
    .or(TradeSetting.where(trade_type: :average_list_hour))
    .maximum(:value)

    to = Time.now - average_time.hour
    self.where("created_at < ?", to.to_s).delete_all
  end

end
