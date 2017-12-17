class ReportsController < ApplicationController
  def pl
    @th = TradeHistory.group_days.order(:timestamp)
    @wallets = Wallet.all
  end
end
