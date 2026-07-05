require "test_helper"

class Agenda::EncountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede", address: "Calle 1"); @branch.ensure_default_schedules!
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    plan = SubscriptionPlan.create!(name: "Elite-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: @user, subscription_plan: plan, plan_name: "Elite", status: "active", current_period_end: 1.year.from_now)
    @appointment = @profile.appointments.create!(doctor_branch: @branch, patient_name: "Ana", appointment_date: Date.new(2026, 7, 6), start_time: "10:00", end_time: "10:30", booking_source: "manual")
    sign_in_as(@user)
  end

  test "edit renders for elite" do
    get edit_agenda_appointment_encounter_path(@appointment)

    assert_response :success
    assert_select "textarea[name=?]", "encounter[evolution_note]"
  end

  test "update persists the encounter" do
    patch agenda_appointment_encounter_path(@appointment), params: { encounter: { evolution_note: "Mejora", heart_rate: 72, blood_pressure: "120/80" } }

    assert_redirected_to agenda_appointment_path(@appointment)
    @appointment.reload
    assert_equal 72, @appointment.encounter.heart_rate
    assert_equal "Mejora", @appointment.encounter.evolution_note
    assert_equal "120/80", @appointment.encounter.blood_pressure
  end

  test "non-elite doctor is blocked" do
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1"); branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    plan = SubscriptionPlan.create!(name: "Pro-#{SecureRandom.hex(3)}", price: 50, interval: "month", profile_type: "doctor", tier: "profesional")
    Subscription.create!(user: user, subscription_plan: plan, plan_name: "Pro", status: "active", current_period_end: 1.year.from_now)
    appointment = profile.appointments.create!(doctor_branch: branch, patient_name: "Ana", appointment_date: Date.new(2026, 7, 6), start_time: "10:00", end_time: "10:30", booking_source: "manual")
    sign_in_as(user)

    get edit_agenda_appointment_encounter_path(appointment)

    assert_redirected_to agenda_patients_path
  end
end
