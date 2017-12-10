class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.string :currency_type, :null => false
      t.decimal :money, precision: 14, scale: 4, :null => false
      t.boolean :is_loscat, :null => false

      t.timestamps
    end
  end
end
