require "test_helper"

class Agenda::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc Test", department: departments(:one), city: cities(:one))
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)

    plan = SubscriptionPlan.create!(name: "Elite", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: @user, subscription_plan: plan, plan_name: "Elite", status: "active", current_period_end: 1.year.from_now)

    sign_in_as(@user)
  end

  test "updating agenda settings persists duration and buffer" do
    patch agenda_settings_url, params: { doctor_agenda_setting: { appointment_duration: 45, buffer_minutes: 10 } }
    assert_redirected_to agenda_settings_path
    assert_equal 45, @profile.reload.agenda_setting.appointment_duration
    assert_equal 10, @profile.agenda_setting.buffer_minutes
  end
end
