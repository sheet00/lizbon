class CreateCurrencyHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_histories do |t|
      t.string :currency_pair, :null => false
      t.string :trade_type, :null => false
      t.decimal :price, precision: 14, scale: 4, :null => false
      t.decimal :amount, precision: 14, scale: 4, :null => false
      t.string :timestamp, :null => false

      t.timestamps

    end
  end
end
