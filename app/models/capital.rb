class Capital < ApplicationRecord
  #Capital.first.buy => TradeHistory.where('id = buy_trade_id')
  belongs_to :bid, class_name: 'TradeHistory', foreign_key: 'bid_trade_id'
  belongs_to :ask, class_name: 'TradeHistory', foreign_key: 'ask_trade_id'

  # 売買の差益を記録する
  # order_id　利益計算元となる売りのorder_id
  def self.cal_trade_capital(sell_order_id)
    sell_row = TradeHistory.where(order_id: sell_order_id).first
    buy_row = TradeHistory
    .where(currency_pair: sell_row.currency_pair)
    .where(your_action: :bid)
    .order("timestamp desc").first

    #前回の購入が見つからない場合は計算しない
    return unless buy_row.present?

    #売り手数料は除く
    sell_contract = sell_row.contract_price - sell_row.fee_amount
    #売りと買いは1:1ではないため、売った数量を基準として、買ったときの金額を算出する
    #売りが分かれた場合、その都度、利益計算される
    buy_contract = buy_row.price * sell_row.amount

    self.create(
      trade_time: Time.at(sell_row.timestamp.to_i),
      currency_pair: sell_row.currency_pair,
      capital: sell_contract - buy_contract,
      bid_trade_id: buy_row.id,
      ask_trade_id: sell_row.id
    )
  end

  #日別利益集計
  def self.group_days
    # select
    #   date (trade_time) day
    #   , sum(capital) as capital
    # from
    #   capitals
    # group by
    #   date (trade_time)

    self.select("
      date (trade_time) day
      , sum(capital) as capital 
      ")
    .group("date (trade_time)")
  end
end
