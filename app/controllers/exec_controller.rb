class ExecController < ApplicationController
  def index
    #価格取得
    GetLastPriceJob.perform_later

    #トレード実行
    TradeJob.perform_later

    #test
    # trade = Trade.new
    # trade.execute()

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'ActiveJobに登録しました。 ' + DateTime.now.to_s}
    end
  end
end
