class AverageAddIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :currency_averages, [:currency_pair]
  end
end
