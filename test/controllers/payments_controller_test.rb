require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get payments_show_url
    assert_redirected_to new_session_path
  end

  test "redirects to dashboard when there is no pending payment" do
    sign_in_as users(:one)
    get payments_show_url
    assert_redirected_to dashboard_path
  end
end
