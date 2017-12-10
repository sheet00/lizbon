require 'test_helper'

class CurrencyPairsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @currency_pair = currency_pairs(:one)
  end

  test "should get index" do
    get currency_pairs_url
    assert_response :success
  end

  test "should get new" do
    get new_currency_pair_url
    assert_response :success
  end

  test "should create currency_pair" do
    assert_difference('CurrencyPair.count') do
      post currency_pairs_url, params: { currency_pair: { currency_pair: @currency_pair.currency_pair, unit_min: @currency_pair.unit_min, unit_step: @currency_pair.unit_step } }
    end

    assert_redirected_to currency_pair_url(CurrencyPair.last)
  end

  test "should show currency_pair" do
    get currency_pair_url(@currency_pair)
    assert_response :success
  end

  test "should get edit" do
    get edit_currency_pair_url(@currency_pair)
    assert_response :success
  end

  test "should update currency_pair" do
    patch currency_pair_url(@currency_pair), params: { currency_pair: { currency_pair: @currency_pair.currency_pair, unit_min: @currency_pair.unit_min, unit_step: @currency_pair.unit_step } }
    assert_redirected_to currency_pair_url(@currency_pair)
  end

  test "should destroy currency_pair" do
    assert_difference('CurrencyPair.count', -1) do
      delete currency_pair_url(@currency_pair)
    end

    assert_redirected_to currency_pairs_url
  end
end
