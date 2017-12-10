class ExecController < ApplicationController
  def index
    trade = Trade.new
    trade.execute()

    respond_to do |format|
      format.html { redirect_to root_path, notice: '取引実行 ' + DateTime.now.to_s }
    end
  end
end
