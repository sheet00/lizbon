class TradeJob < ApplicationJob
  queue_as :default

  def perform(*args)

    #delayでActiveJobsに登録
    trade = Trade.new
    trade.delay(queue: 'Trade.execute').execute()
  end
end
