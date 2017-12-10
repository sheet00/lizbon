class CreateTargets < ActiveRecord::Migration[5.1]
  def change
    create_table :targets do |t|
      t.string :currency_type

      t.timestamps
    end
  end
end
