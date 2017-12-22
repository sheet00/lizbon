class CreateTradeSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :trade_settings do |t|
      t.string :trade_type, :null => false
      t.decimal :value, precision: 10, scale: 4, :null => false

      t.timestamps
    end
  end
end
