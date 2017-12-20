class HomeController < ApplicationController
  def index
    @wallets = Wallet.exclude_order
    @wallet_histories = WalletHistory.order("trade_time desc").take(15)
    @active_orders = ActiveOrder.order("id desc").take(10)
    @trade_histories = TradeHistory.order("timestamp desc, order_id desc").eager_load(:ask_capital).take(100)
    @bots = Bot.order("id desc").take(500)
    @targets = Target.all
    @t_settings = TradeSetting.all
  end
end
