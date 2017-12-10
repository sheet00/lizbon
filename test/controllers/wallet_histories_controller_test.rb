require 'test_helper'

class WalletHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wallet_history = wallet_histories(:one)
  end

  test "should get index" do
    get wallet_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_wallet_history_url
    assert_response :success
  end

  test "should create wallet_history" do
    assert_difference('WalletHistory.count') do
      post wallet_histories_url, params: { wallet_history: { currency_type: @wallet_history.currency_type, money: @wallet_history.money } }
    end

    assert_redirected_to wallet_history_url(WalletHistory.last)
  end

  test "should show wallet_history" do
    get wallet_history_url(@wallet_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_wallet_history_url(@wallet_history)
    assert_response :success
  end

  test "should update wallet_history" do
    patch wallet_history_url(@wallet_history), params: { wallet_history: { currency_type: @wallet_history.currency_type, money: @wallet_history.money } }
    assert_redirected_to wallet_history_url(@wallet_history)
  end

  test "should destroy wallet_history" do
    assert_difference('WalletHistory.count', -1) do
      delete wallet_history_url(@wallet_history)
    end

    assert_redirected_to wallet_histories_url
  end
end
