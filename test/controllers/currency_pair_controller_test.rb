require 'test_helper'

class CurrencyPairControllerTest < ActionDispatch::IntegrationTest
  test "should get currency_pair:string" do
    get currency_pair_currency_pair:string_url
    assert_response :success
  end

  test "should get unit_min:decimal{12,4}" do
    get currency_pair_unit_min:decimal{12,4}_url
    assert_response :success
  end

  test "should get unit_step:decimal{12,4}" do
    get currency_pair_unit_step:decimal{12,4}_url
    assert_response :success
  end

  test "should get digest:integer" do
    get currency_pair_digest:integer_url
    assert_response :success
  end

end
