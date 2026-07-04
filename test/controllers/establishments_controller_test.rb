require "test_helper"

class EstablishmentsControllerTest < ActionDispatch::IntegrationTest
  test "index succeeds when the section is visible" do
    get establishments_url
    assert_response :success
  end

  test "show succeeds when the section is visible" do
    get establishment_url(establishments(:one))
    assert_response :success
  end

  test "index redirects to root when the section is hidden" do
    SiteSetting.find_or_create_by!(key: "establishments").update!(enabled: false)
    get establishments_url
    assert_redirected_to root_path
  end

  test "show redirects to root when the section is hidden" do
    SiteSetting.find_or_create_by!(key: "establishments").update!(enabled: false)
    get establishment_url(establishments(:one))
    assert_redirected_to root_path
  end
end
