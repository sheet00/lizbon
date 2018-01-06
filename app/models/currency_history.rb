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

  # 1時間単位の平均値算出
  def self.group_by_hour
    # select
    #   currency_pair
    #   , date_format(from_unixtime(timestamp), '%Y-%m-%d %H:00:00') timestamp
    #   , avg(price) price
    # from
    #   currency_histories
    # group by
    #   currency_pair
    #   , date_format(from_unixtime(timestamp), '%Y-%m-%d %H:00:00')
    # order by
    #   currency_pair
    #   , date_format(from_unixtime(timestamp), '%Y-%m-%d %H:00:00')

    self
    .select("
      currency_pair
      , date_format(from_unixtime(timestamp), '%Y-%m-%d %H:00:00') timestamp
      , avg(price) price
      ")
    .group("
      currency_pair
      , date_format(from_unixtime(timestamp), '%Y-%m-%d %H:00:00')
      ")
    .order(:currency_pair)
  end
end
