require "test_helper"

class NftControllerTest < ActionDispatch::IntegrationTest
  test "should get nfts" do
    get nfts_url
    assert_response :success
  end

  test "should get endpoint" do
    get endpoint_url
    assert_response :success
  end
end
