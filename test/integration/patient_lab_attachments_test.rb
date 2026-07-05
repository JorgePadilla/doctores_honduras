require "test_helper"

class PatientLabAttachmentsTest < ActionDispatch::IntegrationTest
  test "patient sees lab attachments on their appointment" do
    doctor_user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: doctor_user, name: "Doc", department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)

    patient_user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")
    appt = profile.appointments.create!(doctor_branch: branch, patient_name: "Ana", patient_user_id: patient_user.id,
      appointment_date: Date.new(2026, 7, 6), start_time: "10:00", end_time: "10:30", booking_source: "public_booking")
    appt.lab_attachments.attach(fixture_file_upload("lab_result.pdf", "application/pdf"))

    sign_in_as(patient_user)
    get paciente_appointment_path(appt)
    assert_response :success
    assert_match "lab_result.pdf", @response.body
  end
end
