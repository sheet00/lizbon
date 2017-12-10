class ActiveOrdersController < ApplicationController
  before_action :set_active_order, only: [:show, :edit, :update, :destroy]

  # GET /active_orders
  # GET /active_orders.json
  def index
    @active_orders = ActiveOrder.order("id desc").take(50)
  end

  # GET /active_orders/1
  # GET /active_orders/1.json
  def show
  end

  # GET /active_orders/new
  def new
    @active_order = ActiveOrder.new
  end

  # GET /active_orders/1/edit
  def edit
  end

  # POST /active_orders
  # POST /active_orders.json
  def create
    @active_order = ActiveOrder.new(active_order_params)

    respond_to do |format|
      if @active_order.save
        format.html { redirect_to @active_order, notice: 'Active order was successfully created.' }
        format.json { render :show, status: :created, location: @active_order }
      else
        format.html { render :new }
        format.json { render json: @active_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /active_orders/1
  # PATCH/PUT /active_orders/1.json
  def update
    respond_to do |format|
      if @active_order.update(active_order_params)
        format.html { redirect_to @active_order, notice: 'Active order was successfully updated.' }
        format.json { render :show, status: :ok, location: @active_order }
      else
        format.html { render :edit }
        format.json { render json: @active_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /active_orders/1
  # DELETE /active_orders/1.json
  def destroy
    @active_order.destroy
    respond_to do |format|
      format.html { redirect_to active_orders_url, notice: 'Active order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #未約定キャンセル処理
  #order_idをURL上のIDとする
  def cancel
    order_id = params[:id]
    trade = Trade.new
    trade.order_cancel(order_id)

    redirect_to root_url, notice: "キャンセルしました。"
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_active_order
    @active_order = ActiveOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def active_order_params
    params.require(:active_order)
    .permit(
      :order_id, :currency_pair, :action, :amount, :price,
      :timestamp, :transaction_id, :limit, :contract_price, :lower_limit
    )
  end
end
