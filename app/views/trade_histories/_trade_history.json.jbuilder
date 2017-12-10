json.extract! trade_history, :id, :order_id, :currency_pair, :action, :amount, :price, :fee, :your_action, :timestamp, :comment, :created_at, :updated_at
json.url trade_history_url(trade_history, format: :json)
