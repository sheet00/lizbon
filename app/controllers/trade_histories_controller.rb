class TradeHistoriesController < ApplicationController
  before_action :set_trade_history, only: [:show, :edit, :update, :destroy]

  # GET /trade_histories
  # GET /trade_histories.json
  def index
    @trade_histories = TradeHistory.order("timestamp desc").take(50)
  end

  # GET /trade_histories/1
  # GET /trade_histories/1.json
  def show
  end

  # GET /trade_histories/new
  def new
    @trade_history = TradeHistory.new
  end

  # GET /trade_histories/1/edit
  def edit
  end

  # POST /trade_histories
  # POST /trade_histories.json
  def create
    @trade_history = TradeHistory.new(trade_history_params)

    respond_to do |format|
      if @trade_history.save
        format.html { redirect_to @trade_history, notice: 'Trade history was successfully created.' }
        format.json { render :show, status: :created, location: @trade_history }
      else
        format.html { render :new }
        format.json { render json: @trade_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trade_histories/1
  # PATCH/PUT /trade_histories/1.json
  def update
    respond_to do |format|
      if @trade_history.update(trade_history_params)
        format.html { redirect_to @trade_history, notice: 'Trade history was successfully updated.' }
        format.json { render :show, status: :ok, location: @trade_history }
      else
        format.html { render :edit }
        format.json { render json: @trade_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trade_histories/1
  # DELETE /trade_histories/1.json
  def destroy
    @trade_history.destroy
    respond_to do |format|
      format.html { redirect_to trade_histories_url, notice: 'Trade history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_trade_history
    @trade_history = TradeHistory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trade_history_params
    params.require(:trade_history).permit(
      :order_id, :currency_pair, :action, :amount, :price, :fee, :fee_amount, :your_action, :timestamp, :transaction_id, :contract_price
    )
  end
end
