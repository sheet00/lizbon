require 'test_helper'

class CapitalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @capital = capitals(:one)
  end

  test "should get index" do
    get capitals_url
    assert_response :success
  end

  test "should get new" do
    get new_capital_url
    assert_response :success
  end

  test "should create capital" do
    assert_difference('Capital.count') do
      post capitals_url, params: { capital: { capital: @capital.capital, currency_type: @capital.currency_type, datetime: @capital.datetime, trade_time: @capital.trade_time } }
    end

    assert_redirected_to capital_url(Capital.last)
  end

  test "should show capital" do
    get capital_url(@capital)
    assert_response :success
  end

  test "should get edit" do
    get edit_capital_url(@capital)
    assert_response :success
  end

  test "should update capital" do
    patch capital_url(@capital), params: { capital: { capital: @capital.capital, currency_type: @capital.currency_type, datetime: @capital.datetime, trade_time: @capital.trade_time } }
    assert_redirected_to capital_url(@capital)
  end

  test "should destroy capital" do
    assert_difference('Capital.count', -1) do
      delete capital_url(@capital)
    end

    assert_redirected_to capitals_url
  end
end
