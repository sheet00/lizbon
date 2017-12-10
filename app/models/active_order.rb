class ActiveOrder < ApplicationRecord

  #未成約注文一覧から成約済みデータを削除
  def self.delete_close_order
    #DELETE FROM `active_orders` WHERE `active_orders`.`transaction_id` IN (SELECT `trade_histories`.`transaction_id` FROM `trade_histories`)
    ActiveOrder.where(
      transaction_id: TradeHistory.select(:transaction_id)
    ).delete_all
  end

end
