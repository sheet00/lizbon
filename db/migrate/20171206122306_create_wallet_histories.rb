class CreateWalletHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_histories do |t|
      t.string :currency_type, :null => false
      t.decimal :money, precision: 12, scale: 4, :null => false
      t.datetime :trade_time, :null => false

      t.timestamps
    end
  end
end
