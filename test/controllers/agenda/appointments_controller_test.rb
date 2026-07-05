require "test_helper"

class Agenda::AppointmentsControllerTest < ActionDispatch::IntegrationTest
  MONDAY = Date.new(2026, 7, 6)

  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc Test", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede Central", address: "Calle 1")
    @branch.ensure_default_schedules!
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0, max_concurrent: 1)

    plan = SubscriptionPlan.create!(name: "Elite", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: @user, subscription_plan: plan, plan_name: "Elite", status: "active", current_period_end: 1.year.from_now)

    sign_in_as(@user)
  end

  # C1: the new-appointment form renders the duration select and sobrecupo toggle.
  test "new appointment form renders duration and sobrecupo controls" do
    get new_agenda_appointment_url
    assert_response :success
    assert_select "select[name=?]", "appointment[requested_duration]"
    assert_select "input[name=?]", "appointment[sobrecupo]"
  end

  # C1: the chosen duration is persisted (end_time derived from start + duration).
  test "creating an appointment with a requested duration persists that duration" do
    assert_difference -> { Appointment.count }, 1 do
      post agenda_appointments_url, params: { appointment: {
        doctor_branch_id: @branch.id, patient_name: "Ana", appointment_date: MONDAY.to_s,
        start_time: "10:00", requested_duration: 45
      } }
    end
    appt = Appointment.order(:created_at).last
    assert_equal 45, appt.duration_minutes
    assert_equal "10:45", appt.end_time.strftime("%H:%M")
  end

  # C3: an overbooked (sobrecupo) appointment can be created on top of a full slot.
  test "sobrecupo lets a full slot be booked again" do
    @profile.appointments.create!(doctor_branch: @branch, patient_name: "Primero",
      appointment_date: MONDAY, start_time: "11:00", end_time: "11:30", booking_source: "manual")

    assert_difference -> { Appointment.count }, 1 do
      post agenda_appointments_url, params: { appointment: {
        doctor_branch_id: @branch.id, patient_name: "Segundo", appointment_date: MONDAY.to_s,
        start_time: "11:00", end_time: "11:30", sobrecupo: "1"
      } }
    end
    assert Appointment.order(:created_at).last.sobrecupo?
  end

  # C5: the Secretarias link is present in the agenda nav for the doctor.
  test "agenda index shows a Secretarias link" do
    get agenda_appointments_url
    assert_response :success
    assert_select "a[href=?]", agenda_secretaries_path, text: "Secretarias"
  end

  test "secretaries index is reachable" do
    get agenda_secretaries_url
    assert_response :success
  end
end
