class CreateTradeSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :trade_settings do |t|
      t.string :trade_type, :null => false
      t.decimal :percent, precision: 6, scale: 4, :null => false

      t.timestamps
    end
  end
end
