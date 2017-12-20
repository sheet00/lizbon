class ReportsController < ApplicationController
  def pl
    @th = TradeHistory.group_days.order(:timestamp)
    @capitals = Capital.group_days.order("day")
    @wallets = Wallet.all
  end
end
