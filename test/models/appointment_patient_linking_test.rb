require "test_helper"

class AppointmentPatientLinkingTest < ActiveSupport::TestCase
  # A Monday, so the default Mon-Sat branch schedule (08:00-17:00) applies.
  MONDAY = Date.new(2026, 7, 6)

  setup do
    @profile = create_doctor_with_agenda
    @branch = @profile.doctor_branches.first
  end

  def create_doctor_with_agenda(name: "Doc")
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: name, department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    profile
  end

  def create_appointment(profile, attrs = {})
    profile.appointments.create!({
      doctor_branch: profile.doctor_branches.first,
      patient_name: "Ana",
      appointment_date: MONDAY,
      start_time: "10:00",
      end_time: "10:30",
      booking_source: "manual"
    }.merge(attrs))
  end

  test "saving an appointment with only patient_name auto-creates and links a Patient" do
    appt = create_appointment(@profile, patient_name: "Ana")

    assert_not_nil appt.patient
    assert appt.patient_id.present?
    assert_equal "Ana", appt.patient.name
    assert_equal @profile.id, appt.patient.doctor_profile_id
  end

  test "two appointments with the same patient_name share one Patient" do
    first = create_appointment(@profile, patient_name: "Ana", start_time: "10:00", end_time: "10:30")
    second = create_appointment(@profile, patient_name: "Ana", start_time: "11:00", end_time: "11:30")

    assert_equal 1, Patient.where(doctor_profile: @profile).count
    assert_equal first.patient_id, second.patient_id
  end

  test "an appointment carrying patient_user_id links to a Patient with that user_id" do
    patient_user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")

    appt = create_appointment(@profile, patient_name: "Ana", patient_user_id: patient_user.id)

    assert_not_nil appt.patient
    assert_equal patient_user.id, appt.patient.user_id
  end

  test "two different doctors with the same patient_name get separate Patients" do
    other = create_doctor_with_agenda(name: "Other Doc")

    a = create_appointment(@profile, patient_name: "Ana")
    b = create_appointment(other, patient_name: "Ana")

    assert_not_equal a.patient_id, b.patient_id
    assert_equal @profile.id, a.patient.doctor_profile_id
    assert_equal other.id, b.patient.doctor_profile_id
  end
end
