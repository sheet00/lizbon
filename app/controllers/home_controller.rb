class HomeController < ApplicationController
  def index
    @wallets = Wallet.exclude_order
    @active_orders = ActiveOrder.order("id desc")
    @trade_histories = TradeHistory.order("timestamp desc, order_id desc").eager_load(:ask_capital).take(100)
    @bots = Bot.order("id desc").take(500)
    @targets = Target.all
    @t_settings = TradeSetting.all
    @capitals = Capital.group_days.order("day desc").take(16)
  end
end
