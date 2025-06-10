require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get plan_selection" do
    get onboarding_plan_selection_url
    assert_response :success
  end

  test "should get plan_confirmation" do
    get onboarding_plan_confirmation_url
    assert_response :success
  end

  test "should get profile_setup" do
    get onboarding_profile_setup_url
    assert_response :success
  end

  test "should get profile_confirmation" do
    get onboarding_profile_confirmation_url
    assert_response :success
  end
end
