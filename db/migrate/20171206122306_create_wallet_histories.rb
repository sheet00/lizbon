class CreateWalletHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_histories do |t|
      t.string :currency_type
      t.decimal :money, precision: 12, scale: 4

      t.timestamps
    end
  end
end
