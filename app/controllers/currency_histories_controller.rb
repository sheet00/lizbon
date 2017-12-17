class CurrencyHistoriesController < ApplicationController
  before_action :set_currency_history, only: [:show, :edit, :update, :destroy]

  # GET /currency_histories
  # GET /currency_histories.json
  def index
    @currency_histories = CurrencyHistory.order("timestamp desc").take(500)
  end

  # GET /currency_histories/1
  # GET /currency_histories/1.json
  def show
  end

  # GET /currency_histories/new
  def new
    @currency_history = CurrencyHistory.new
  end

  # GET /currency_histories/1/edit
  def edit
  end

  # POST /currency_histories
  # POST /currency_histories.json
  def create
    @currency_history = CurrencyHistory.new(currency_history_params)

    respond_to do |format|
      if @currency_history.save
        format.html { redirect_to @currency_history, notice: 'Currency history was successfully created.' }
        format.json { render :show, status: :created, location: @currency_history }
      else
        format.html { render :new }
        format.json { render json: @currency_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /currency_histories/1
  # PATCH/PUT /currency_histories/1.json
  def update
    respond_to do |format|
      if @currency_history.update(currency_history_params)
        format.html { redirect_to @currency_history, notice: 'Currency history was successfully updated.' }
        format.json { render :show, status: :ok, location: @currency_history }
      else
        format.html { render :edit }
        format.json { render json: @currency_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /currency_histories/1
  # DELETE /currency_histories/1.json
  def destroy
    @currency_history.destroy
    respond_to do |format|
      format.html { redirect_to currency_histories_url, notice: 'Currency history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_currency_history
    @currency_history = CurrencyHistory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def currency_history_params
    params.require(:currency_history)
    .permit(
      :currency_pair,
      :trade_type,
      :price,
      :amount,
      :timestamp
    )
  end
end
