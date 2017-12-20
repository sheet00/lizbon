class TradeHistory < ApplicationRecord
  has_one :bid_capital, class_name: 'Capital',foreign_key: 'bid_trade_id'
  has_one :ask_capital, class_name: 'Capital',foreign_key: 'ask_trade_id'

  #日グループ売買実績
  def self.group_days
    # select
    #   DATE (from_unixtime(timestamp)) as day
    #   , sum(contract_price) as contract_price
    #   , your_action
    # from
    #   trade_histories
    # group by
    #   DATE (from_unixtime(timestamp))
    #   , your_action

    self
    .select("
  DATE (from_unixtime(timestamp)) as day
  , sum(contract_price) as contract_price
  , your_action
  , count(*) as count 
      ")
    .group(" DATE (from_unixtime(timestamp)), your_action")
  end

end
