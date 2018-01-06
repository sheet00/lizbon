class CreateCurrencyAverages < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_averages do |t|

      t.string :currency_pair, :null => false
      t.decimal :price, precision: 14, scale: 4, :null => false
      t.datetime :timestamp, :null => false

      t.timestamps
    end
  end
end
