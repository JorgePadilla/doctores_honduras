require "test_helper"

class PrescriptionItemTest < ActiveSupport::TestCase
  setup do
    appointment = make_appointment
    @prescription = Prescription.create!(appointment: appointment)
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

  def build_item(attrs = {})
    PrescriptionItem.new({ prescription: @prescription }.merge(attrs))
  end

  # --- validations ---

  test "medication is required" do
    item = build_item(medication: nil)
    assert_not item.valid?
    assert item.errors[:medication].any?
  end

  test "valid with a medication present" do
    item = build_item(medication: "Amoxicilina")
    assert item.valid?, item.errors.full_messages.to_sentence
  end

  # --- summary_line ---

  test "summary_line joins all present parts with a middot separator" do
    item = build_item(medication: "Amoxicilina", dosage: "500mg", frequency: "cada 8h", duration: "7 días")
    assert_equal "Amoxicilina · 500mg · cada 8h · 7 días", item.summary_line
  end

  test "summary_line skips blank parts" do
    item = build_item(medication: "Amoxicilina", dosage: "500mg")
    assert_equal "Amoxicilina · 500mg", item.summary_line
  end
end
