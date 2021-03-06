class ReportsController < ApplicationController

  def pl
    @th = TradeHistory.group_days.order(:timestamp)
    @capitals = Capital.group_days.order("day")
    @wallets = Wallet.all
  end

  def average
    @average = {}
    Target.all.each{|t|
      @average[t.currency_type] = CurrencyAverage.where(currency_pair: "#{t.currency_type}_jpy")
    }
  end

  def jobs
    @jobs = DelayedJob.all.order("run_at desc")
  end

  def jobs_delete
    DelayedJob.delete_all
    redirect_to reports_jobs_path, notice: '削除しました。'
  end

end
