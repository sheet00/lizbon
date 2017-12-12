class CurrencyHistoryAddIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :currency_histories, [:currency_pair,:timestamp]
  end
end
