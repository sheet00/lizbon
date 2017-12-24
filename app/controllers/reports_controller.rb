class ReportsController < ApplicationController

  def pl
    @th = TradeHistory.group_days.order(:timestamp)
    @capitals = Capital.group_days.order("day")
    @wallets = Wallet.all
  end

  def average
    trade = Trade.new

    @average = {}
    Target.all.each{|t|
      @average[t.currency_type] = trade.get_average_list(t.currency_type)
    }
  end

  def jobs
    @jobs = DelayedJob.all.order("run_at desc")
  end

end
