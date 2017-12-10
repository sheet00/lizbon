require 'test_helper'

class ActiveOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @active_order = active_orders(:one)
  end

  test "should get index" do
    get active_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_active_order_url
    assert_response :success
  end

  test "should create active_order" do
    assert_difference('ActiveOrder.count') do
      post active_orders_url, params: { active_order: { action: @active_order.action, amount: @active_order.amount, contract_price: @active_order.contract_price, currency_pair: @active_order.currency_pair, limit: @active_order.limit, order_id: @active_order.order_id, price: @active_order.price, timestamp: @active_order.timestamp, transaction_id: @active_order.transaction_id } }
    end

    assert_redirected_to active_order_url(ActiveOrder.last)
  end

  test "should show active_order" do
    get active_order_url(@active_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_active_order_url(@active_order)
    assert_response :success
  end

  test "should update active_order" do
    patch active_order_url(@active_order), params: { active_order: { action: @active_order.action, amount: @active_order.amount, contract_price: @active_order.contract_price, currency_pair: @active_order.currency_pair, limit: @active_order.limit, order_id: @active_order.order_id, price: @active_order.price, timestamp: @active_order.timestamp, transaction_id: @active_order.transaction_id } }
    assert_redirected_to active_order_url(@active_order)
  end

  test "should destroy active_order" do
    assert_difference('ActiveOrder.count', -1) do
      delete active_order_url(@active_order)
    end

    assert_redirected_to active_orders_url
  end
end
