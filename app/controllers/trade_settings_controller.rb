class TradeSettingsController < ApplicationController
  before_action :set_trade_setting, only: [:show, :edit, :update, :destroy]

  # GET /trade_settings
  # GET /trade_settings.json
  def index
    @trade_settings = TradeSetting.all
  end

  # GET /trade_settings/1
  # GET /trade_settings/1.json
  def show
  end

  # GET /trade_settings/new
  def new
    @trade_setting = TradeSetting.new
  end

  # GET /trade_settings/1/edit
  def edit
  end

  # POST /trade_settings
  # POST /trade_settings.json
  def create
    @trade_setting = TradeSetting.new(trade_setting_params)

    respond_to do |format|
      if @trade_setting.save
        format.html { redirect_to @trade_setting, notice: 'Trade setting was successfully created.' }
        format.json { render :show, status: :created, location: @trade_setting }
      else
        format.html { render :new }
        format.json { render json: @trade_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trade_settings/1
  # PATCH/PUT /trade_settings/1.json
  def update
    respond_to do |format|
      if @trade_setting.update(trade_setting_params)
        format.html { redirect_to @trade_setting, notice: 'Trade setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @trade_setting }
      else
        format.html { render :edit }
        format.json { render json: @trade_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trade_settings/1
  # DELETE /trade_settings/1.json
  def destroy
    @trade_setting.destroy
    respond_to do |format|
      format.html { redirect_to trade_settings_url, notice: 'Trade setting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_trade_setting
    @trade_setting = TradeSetting.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trade_setting_params
    params.require(:trade_setting).permit(:trade_type, :value)
  end
end
