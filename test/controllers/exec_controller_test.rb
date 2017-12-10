require 'test_helper'

class ExecControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exec_index_url
    assert_response :success
  end

end
