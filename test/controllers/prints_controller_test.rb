require "test_helper"

class PrintsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prints_index_url
    assert_response :success
  end

  test "should get show" do
    get prints_show_url
    assert_response :success
  end
end
