require "test_helper"

class PatientProfileTest < ActiveSupport::TestCase
  def paciente
    @paciente ||= User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")
  end

  test "identity_document is required" do
    profile = PatientProfile.new(user: paciente, name: "Ana")
    assert_not profile.valid?
    assert profile.errors[:identity_document].any?
  end

  test "identity_document must have 13 digits (dashes allowed)" do
    assert PatientProfile.new(user: paciente, name: "Ana", identity_document: "0801-1990-12345").valid?
    assert PatientProfile.new(user: paciente, name: "Ana", identity_document: "0801199012345").valid?
    assert_not PatientProfile.new(user: paciente, name: "Ana", identity_document: "123").valid?
  end

  test "a registered patient's DNI flows to the canonical Patient" do
    patient_user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")
    PatientProfile.create!(user: patient_user, name: "Ana", identity_document: "0801-1990-12345")

    doctor = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: doctor, name: "Doc", department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)

    appt = profile.appointments.create!(doctor_branch: branch, patient_name: "Ana", patient_user_id: patient_user.id,
      appointment_date: Date.new(2026, 7, 6), start_time: "10:00", end_time: "10:30", booking_source: "public_booking")

    assert_equal "0801-1990-12345", appt.patient.identity_document
  end
end
