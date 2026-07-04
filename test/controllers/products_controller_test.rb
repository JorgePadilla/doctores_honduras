require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get supplier_products_url(suppliers(:one))
    assert_response :success
  end

  test "should get show" do
    get supplier_product_url(suppliers(:one), products(:one))
    assert_response :success
  end

  test "redirects to root when the suppliers section is hidden" do
    SiteSetting.find_or_create_by!(key: "suppliers").update!(enabled: false)
    get supplier_products_url(suppliers(:one))
    assert_redirected_to root_path
  end
end
