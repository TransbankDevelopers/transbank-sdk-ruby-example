require "test_helper"

class ProductIndexControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_index_index_url
    assert_response :success
  end
end
