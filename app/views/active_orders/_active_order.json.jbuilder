json.extract! active_order, :id, :order_id, :currency_pair, :action, :amount, :price, :timestamp, :transaction_id, :limit, :contract_price, :created_at, :updated_at
json.url active_order_url(active_order, format: :json)
