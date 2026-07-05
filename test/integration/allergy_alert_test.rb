require "test_helper"

# G2: a doctor opening a cita must immediately see the patient's allergy /
# critical-info alert on the appointment detail page.
class AllergyAlertTest < ActionDispatch::IntegrationTest
  MONDAY = Date.new(2026, 7, 6)

  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    @branch.ensure_default_schedules!
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    plan = SubscriptionPlan.create!(name: "Elite-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: @user, subscription_plan: plan, plan_name: "Elite", status: "active", current_period_end: 1.year.from_now)
    sign_in_as(@user)
  end

  test "appointment detail surfaces the allergy alert for a patient with allergies" do
    patient = @profile.patients.create!(name: "Ana")
    patient.create_clinical_record!(allergies: "Penicilina")
    appt = @profile.appointments.create!(doctor_branch: @branch, patient: patient, patient_name: "Ana",
      appointment_date: MONDAY, start_time: "10:00", end_time: "10:30", booking_source: "manual")

    get agenda_appointment_path(appt)
    assert_response :success
    assert_match "Alergias e información crítica", @response.body
    assert_match "Penicilina", @response.body
  end

  test "appointment detail hides the allergy alert for a patient without allergies" do
    patient = @profile.patients.create!(name: "Beto")
    appt = @profile.appointments.create!(doctor_branch: @branch, patient: patient, patient_name: "Beto",
      appointment_date: MONDAY, start_time: "11:00", end_time: "11:30", booking_source: "manual")

    get agenda_appointment_path(appt)
    assert_response :success
    assert_not_includes @response.body, "Alergias e información crítica"
  end
end
