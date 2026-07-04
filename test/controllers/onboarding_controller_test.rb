require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get onboarding_profile_type_url
    assert_response :redirect
  end

  test "signed-in user can view the profile type selection" do
    sign_in_as users(:one)
    get onboarding_profile_type_url
    assert_response :success
  end

  test "selecting doctor sets the profile type and advances to basic info" do
    sign_in_as users(:one)
    post onboarding_save_profile_type_url, params: { profile_type: "doctor" }
    assert_redirected_to onboarding_basic_info_path
    assert_equal "doctor", users(:one).reload.profile_type
  end

  test "vendor selection is rejected when the suppliers section is hidden" do
    SiteSetting.find_or_create_by!(key: "suppliers").update!(enabled: false)
    sign_in_as users(:one)
    post onboarding_save_profile_type_url, params: { profile_type: "vendor" }
    assert_redirected_to onboarding_profile_type_path
    assert_nil users(:one).reload.profile_type
  end

  test "hospital selection is rejected when the establishments section is hidden" do
    SiteSetting.find_or_create_by!(key: "establishments").update!(enabled: false)
    sign_in_as users(:one)
    post onboarding_save_profile_type_url, params: { profile_type: "hospital" }
    assert_redirected_to onboarding_profile_type_path
    assert_nil users(:one).reload.profile_type
  end
end
