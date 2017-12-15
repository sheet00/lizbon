class WalletHistoriesController < ApplicationController
  before_action :set_wallet_history, only: [:show, :edit, :update, :destroy]

  # GET /wallet_histories
  # GET /wallet_histories.json
  def index
    from = DateTime.now - 7.days
    @wallet_histories = WalletHistory.where("? <= trade_time",from).order("trade_time desc")
  end

  # GET /wallet_histories/1
  # GET /wallet_histories/1.json
  def show
  end

  # GET /wallet_histories/new
  def new
    @wallet_history = WalletHistory.new
  end

  # GET /wallet_histories/1/edit
  def edit
  end

  # POST /wallet_histories
  # POST /wallet_histories.json
  def create
    @wallet_history = WalletHistory.new(wallet_history_params)

    respond_to do |format|
      if @wallet_history.save
        format.html { redirect_to @wallet_history, notice: 'Wallet history was successfully created.' }
        format.json { render :show, status: :created, location: @wallet_history }
      else
        format.html { render :new }
        format.json { render json: @wallet_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallet_histories/1
  # PATCH/PUT /wallet_histories/1.json
  def update
    respond_to do |format|
      if @wallet_history.update(wallet_history_params)
        format.html { redirect_to @wallet_history, notice: 'Wallet history was successfully updated.' }
        format.json { render :show, status: :ok, location: @wallet_history }
      else
        format.html { render :edit }
        format.json { render json: @wallet_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallet_histories/1
  # DELETE /wallet_histories/1.json
  def destroy
    @wallet_history.destroy
    respond_to do |format|
      format.html { redirect_to wallet_histories_url, notice: 'Wallet history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_wallet_history
    @wallet_history = WalletHistory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wallet_history_params
    params.require(:wallet_history).permit(:currency_type, :money, :trade_time)
  end
end
