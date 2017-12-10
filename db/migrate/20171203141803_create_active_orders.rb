class CreateActiveOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :active_orders do |t|
      t.integer :order_id, :null => false
      t.string :currency_pair, :null => false
      t.string :action, :null => false
      t.decimal :amount, precision: 12, scale: 4, :null => false
      t.decimal :price, precision: 12, scale: 4, :null => false
      t.string :timestamp, :null => false
      t.string :transaction_id, :null => false
      t.decimal :limit, precision: 12, scale: 4
      t.decimal :contract_price, precision: 12, scale: 4, :null => false
      t.decimal :lower_limit, precision: 12, scale: 4

      t.timestamps
    end
  end
end
