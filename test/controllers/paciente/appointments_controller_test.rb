require "test_helper"

class Paciente::AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @doctor_user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @doctor_user, name: "Doc", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    @branch.ensure_default_schedules!
    @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)

    @patient_user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")

    @appointment = @profile.appointments.create!(
      doctor_branch: @branch,
      patient_name: "Ana",
      patient_user_id: @patient_user.id,
      appointment_date: Date.new(2026, 7, 6),
      start_time: "10:00",
      end_time: "10:30",
      booking_source: "public_booking"
    )
    @appointment.create_encounter!(evolution_note: "NOTA_INTERNA_SECRETA", blood_pressure: "120/80", heart_rate: 72)
    pres = @appointment.create_prescription!(instructions: "Tomar con agua")
    pres.prescription_items.create!(medication: "Amoxicilina", dosage: "500mg")

    sign_in_as(@patient_user)
  end

  test "patient sees vitals on their appointment" do
    get paciente_appointment_path(@appointment)

    assert_response :success
    assert_match "120/80", @response.body
  end

  test "patient sees prescription on their appointment" do
    get paciente_appointment_path(@appointment)

    assert_response :success
    assert_match "Amoxicilina", @response.body
  end

  test "patient never sees the doctor's evolution note" do
    get paciente_appointment_path(@appointment)

    assert_response :success
    assert_no_match "NOTA_INTERNA_SECRETA", @response.body
  end
end
