require "test_helper"

class EncounterTest < ActiveSupport::TestCase
  setup do
    @appointment = make_appointment
  end

  # A Monday, so the default Mon-Sat branch schedule applies.
  def make_appointment
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    profile.appointments.create!(
      doctor_branch: branch,
      patient_name: "Ana",
      appointment_date: Date.new(2026, 7, 6),
      start_time: "10:00",
      end_time: "10:30",
      booking_source: "manual"
    )
  end

  def build_encounter(attrs = {})
    Encounter.new({ appointment: @appointment }.merge(attrs))
  end

  # --- vitals? / any_data? ---

  test "vitals? is false when no vital is present" do
    assert_not build_encounter.vitals?
  end

  test "vitals? is true when a vital such as blood_pressure is present" do
    assert build_encounter(blood_pressure: "120/80").vitals?
  end

  test "any_data? is true when only the evolution_note is present" do
    encounter = build_encounter(evolution_note: "Paciente estable")
    assert_not encounter.vitals?
    assert encounter.any_data?
  end

  test "any_data? is false on an empty encounter" do
    assert_not build_encounter.any_data?
  end

  # --- validations ---

  test "an empty encounter (all blanks) is valid" do
    encounter = build_encounter
    assert encounter.valid?, encounter.errors.full_messages.to_sentence
  end

  test "oxygen_saturation of 98 is valid" do
    encounter = build_encounter(oxygen_saturation: 98)
    assert encounter.valid?, encounter.errors.full_messages.to_sentence
  end

  test "oxygen_saturation of 101 is invalid (above 100)" do
    encounter = build_encounter(oxygen_saturation: 101)
    assert_not encounter.valid?
    assert encounter.errors[:oxygen_saturation].any?
  end

  test "heart_rate of 0 is invalid (must be greater than 0)" do
    encounter = build_encounter(heart_rate: 0)
    assert_not encounter.valid?
    assert encounter.errors[:heart_rate].any?
  end

  test "heart_rate of 72 is valid" do
    encounter = build_encounter(heart_rate: 72)
    assert encounter.valid?, encounter.errors.full_messages.to_sentence
  end

  test "temperature of 36.6 is valid" do
    encounter = build_encounter(temperature: 36.6)
    assert encounter.valid?, encounter.errors.full_messages.to_sentence
  end

  test "temperature of 0 is invalid (must be greater than 0)" do
    encounter = build_encounter(temperature: 0)
    assert_not encounter.valid?
    assert encounter.errors[:temperature].any?
  end

  # --- delegation ---

  test "doctor_profile delegates to the appointment" do
    encounter = build_encounter
    assert_equal @appointment.doctor_profile, encounter.doctor_profile
  end

  test "patient delegates to the appointment" do
    encounter = build_encounter
    assert_equal @appointment.patient, encounter.patient
  end
end
