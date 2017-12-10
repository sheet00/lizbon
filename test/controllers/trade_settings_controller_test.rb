require 'test_helper'

class TradeSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trade_setting = trade_settings(:one)
  end

  test "should get index" do
    get trade_settings_url
    assert_response :success
  end

  test "should get new" do
    get new_trade_setting_url
    assert_response :success
  end

  test "should create trade_setting" do
    assert_difference('TradeSetting.count') do
      post trade_settings_url, params: { trade_setting: { percent: @trade_setting.percent, trade_type: @trade_setting.trade_type } }
    end

    assert_redirected_to trade_setting_url(TradeSetting.last)
  end

  test "should show trade_setting" do
    get trade_setting_url(@trade_setting)
    assert_response :success
  end

  test "should get edit" do
    get edit_trade_setting_url(@trade_setting)
    assert_response :success
  end

  test "should update trade_setting" do
    patch trade_setting_url(@trade_setting), params: { trade_setting: { percent: @trade_setting.percent, trade_type: @trade_setting.trade_type } }
    assert_redirected_to trade_setting_url(@trade_setting)
  end

  test "should destroy trade_setting" do
    assert_difference('TradeSetting.count', -1) do
      delete trade_setting_url(@trade_setting)
    end

    assert_redirected_to trade_settings_url
  end
end
