class GetLastPriceJob < ApplicationJob
  queue_as :default

  # 1.価格取得
  # 2.移動平均計算
  def perform(*args)
    price = GetPrice.new
    price.delay(queue: 'GetPrice.execute').execute
  end
end
