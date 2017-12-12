class Zaif_Extend < Zaif::API

  # commentを追加


  # Issue trade.
  # Need api key.
  def trade(currency_code, price, amount, action, counter_currency_code = "jpy", comment = "bot")
    currency_pair = currency_code + "_" + counter_currency_code
    json = post_ssl(@zaif_trade_url, "trade", {:currency_pair => currency_pair, :action => action, :price => price, :amount => amount, :comment => comment})
    return json
  end

  # Issue bid order.
  # Need api key.
  def bid(currency_code, price, amount, counter_currency_code = "jpy", comment = "bot")
    return trade(currency_code, price, amount, "bid", counter_currency_code, comment)
  end

  # Issue ask order.
  # Need api key.
  def ask(currency_code, price, amount, counter_currency_code = "jpy", comment = "bot")
    return trade(currency_code, price, amount, "ask", counter_currency_code, comment)
  end

  # Cancel order.
  # Need api key.
  # トークン系はcurrency_pair必須
  def cancel(order_id,currency_pair)
    json = post_ssl(@zaif_trade_url, "cancel_order", {:order_id => order_id, :currency_pair => currency_pair})
    return json
  end
end
