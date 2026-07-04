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

  test "index redirects to root when the suppliers section is hidden" do
    SiteSetting.find_or_create_by!(key: "suppliers").update!(enabled: false)
    get suppliers_url
    assert_redirected_to root_path
  end
end
