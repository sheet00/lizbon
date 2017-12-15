class HomeController < ApplicationController
  def index
    @wallets = Wallet.all
    @wallet_histories = WalletHistory.order("trade_time desc").take(15)
    @active_orders = ActiveOrder.order("id desc").take(10)
    @trade_histories = TradeHistory.order("timestamp desc").take(100)
    @bots = Bot.order("id desc").take(500)
    @t_settings = TradeSetting.all
  end
end
