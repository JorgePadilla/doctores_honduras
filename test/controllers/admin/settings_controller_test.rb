require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "non-admin is redirected away" do
    sign_in_as users(:one)
    get admin_settings_url
    assert_redirected_to root_path
  end

  test "admin can view the settings page with the section toggles" do
    sign_in_as users(:admin)
    get admin_settings_url
    assert_response :success
    assert_select "input[name=?]", "sections[suppliers]"
    assert_select "input[name=?]", "sections[establishments]"
  end

  test "admin update persists section visibility" do
    sign_in_as users(:admin)
    patch admin_settings_url, params: { sections: { suppliers: "0", establishments: "1" } }
    assert_redirected_to admin_settings_path
    assert_not SiteSetting.section_enabled?("suppliers")
    assert SiteSetting.section_enabled?("establishments")
  end
end
