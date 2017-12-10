json.extract! currency_history, :id, :currency_type, :price, :created_at, :updated_at
json.url currency_history_url(currency_history, format: :json)
