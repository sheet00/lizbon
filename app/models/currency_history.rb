class CurrencyHistory < ApplicationRecord

  # 実行日からn時間前のログ削除
  def self.delete_before_day
    self.where("created_at < ?", 12.hour.ago.to_s).delete_all
  end

end
