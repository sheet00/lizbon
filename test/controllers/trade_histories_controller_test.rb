require 'test_helper'

class TradeHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trade_history = trade_histories(:one)
  end

  test "should get index" do
    get trade_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_trade_history_url
    assert_response :success
  end

  test "should create trade_history" do
    assert_difference('TradeHistory.count') do
      post trade_histories_url, params: { trade_history: { action: @trade_history.action, amount: @trade_history.amount, comment: @trade_history.comment, currency_pair: @trade_history.currency_pair, fee: @trade_history.fee, order_id: @trade_history.order_id, price: @trade_history.price, timestamp: @trade_history.timestamp, your_action: @trade_history.your_action } }
    end

    assert_redirected_to trade_history_url(TradeHistory.last)
  end

  test "should show trade_history" do
    get trade_history_url(@trade_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_trade_history_url(@trade_history)
    assert_response :success
  end

  test "should update trade_history" do
    patch trade_history_url(@trade_history), params: { trade_history: { action: @trade_history.action, amount: @trade_history.amount, comment: @trade_history.comment, currency_pair: @trade_history.currency_pair, fee: @trade_history.fee, order_id: @trade_history.order_id, price: @trade_history.price, timestamp: @trade_history.timestamp, your_action: @trade_history.your_action } }
    assert_redirected_to trade_history_url(@trade_history)
  end

  test "should destroy trade_history" do
    assert_difference('TradeHistory.count', -1) do
      delete trade_history_url(@trade_history)
    end

    assert_redirected_to trade_histories_url
  end
end
