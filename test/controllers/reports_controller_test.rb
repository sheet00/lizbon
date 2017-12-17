require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get pl" do
    get reports_pl_url
    assert_response :success
  end

end
