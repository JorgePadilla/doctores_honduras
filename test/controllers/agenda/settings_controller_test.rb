require "test_helper"

class Agenda::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc Test", department: departments(:one), city: cities(:one))
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0, max_concurrent: 1)

    plan = SubscriptionPlan.create!(name: "Elite", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: @user, subscription_plan: plan, plan_name: "Elite", status: "active", current_period_end: 1.year.from_now)

    sign_in_as(@user)
  end

  # C2: the concurrency limit is configurable from the agenda settings.
  test "updating max_concurrent persists the new limit" do
    patch agenda_settings_url, params: { doctor_agenda_setting: { appointment_duration: 30, buffer_minutes: 0, max_concurrent: 3 } }
    assert_redirected_to agenda_settings_path
    assert_equal 3, @profile.reload.agenda_setting.max_concurrent
  end

  test "max_concurrent below 1 is rejected" do
    @profile.agenda_setting.update!(max_concurrent: 2)
    patch agenda_settings_url, params: { doctor_agenda_setting: { appointment_duration: 30, buffer_minutes: 0, max_concurrent: 0 } }
    assert_response :unprocessable_entity
    assert_equal 2, @profile.reload.agenda_setting.max_concurrent
  end
end
