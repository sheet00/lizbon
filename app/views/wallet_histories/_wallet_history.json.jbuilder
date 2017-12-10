json.extract! wallet_history, :id, :currency_type, :money, :created_at, :updated_at
json.url wallet_history_url(wallet_history, format: :json)
