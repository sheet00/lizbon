class CurrencyHistory < ApplicationRecord

  # 実行日からn時間前のログ削除
  def self.delete_before_log
    average_min = TradeSetting.where(trade_type: :sell_lower_min).first.value
    to = Time.now - average_min.minute
    self.where("created_at < ?", to.to_s).delete_all
  end

end
