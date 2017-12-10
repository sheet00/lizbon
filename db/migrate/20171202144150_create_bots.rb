class CreateBots < ActiveRecord::Migration[5.1]
  def change
    create_table :bots do |t|
      t.string :currency_type, :null => false
      t.string :trade_type, :null => false

      t.timestamps
    end
  end
end
