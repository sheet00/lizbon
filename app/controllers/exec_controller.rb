class ExecController < ApplicationController
  def index

    TradeJob.perform_later

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'ActiveJobに登録しました。 ' + DateTime.now.to_s}
    end
  end
end
