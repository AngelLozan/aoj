require "test_helper"

class NftControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get nft_index_url
    assert_response :success
  end

  test "should get show" do
    get nft_show_url
    assert_response :success
  end
end
