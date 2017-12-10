require 'test_helper'

class CurrencyHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @currency_history = currency_histories(:one)
  end

  test "should get index" do
    get currency_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_currency_history_url
    assert_response :success
  end

  test "should create currency_history" do
    assert_difference('CurrencyHistory.count') do
      post currency_histories_url, params: { currency_history: { currency_type: @currency_history.currency_type, price: @currency_history.price } }
    end

    assert_redirected_to currency_history_url(CurrencyHistory.last)
  end

  test "should show currency_history" do
    get currency_history_url(@currency_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_currency_history_url(@currency_history)
    assert_response :success
  end

  test "should update currency_history" do
    patch currency_history_url(@currency_history), params: { currency_history: { currency_type: @currency_history.currency_type, price: @currency_history.price } }
    assert_redirected_to currency_history_url(@currency_history)
  end

  test "should destroy currency_history" do
    assert_difference('CurrencyHistory.count', -1) do
      delete currency_history_url(@currency_history)
    end

    assert_redirected_to currency_histories_url
  end
end
