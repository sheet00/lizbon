class CurrencyHistory < ApplicationRecord

  # 実行日からn時間前のログ削除
  def self.delete_before_log
    #売り下限時間、移動平均確認時間、両者のうち、長いほうに合わせて削除する
    average_min = TradeSetting
    .where(trade_type: :sell_lower_min)
    .or(TradeSetting.where(trade_type: :average_list_min))
    .maximum(:value)

    ap average_min

    to = Time.now - average_min.minute
    self.where("created_at < ?", to.to_s).delete_all
  end

end
