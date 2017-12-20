class CreateCapitals < ActiveRecord::Migration[5.1]
  def change
    create_table :capitals do |t|
      t.datetime :trade_time, :null => false
      t.string :currency_pair, :null => false
      t.decimal :capital, precision: 12, scale: 4, :null => false
      t.integer :bid_trade_id, :null => false, index: true
      t.integer :ask_trade_id, :null => false, index: true

      t.timestamps
    end
  end
end
