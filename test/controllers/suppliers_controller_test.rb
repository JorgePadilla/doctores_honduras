require "test_helper"

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get suppliers_url
    assert_response :success
  end

  test "should get show" do
    get supplier_url(id: suppliers(:one).id)
    assert_response :success
  end
end
