class CreateCurrencyPairs < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_pairs do |t|
      t.string :currency_pair, :null => false
      t.decimal :unit_min, precision: 12, scale: 4, :null => false
      t.decimal :unit_step, precision: 12, scale: 4, :null => false
      t.integer :unit_digest, :null => false
      t.integer :currency_digest, :null => false

      t.timestamps
    end
  end
end
