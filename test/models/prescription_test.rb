require "test_helper"

class PrescriptionTest < ActiveSupport::TestCase
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

  # --- any_items? ---

  test "any_items? is false with no items and true once an item exists" do
    prescription = Prescription.create!(appointment: @appointment)
    assert_not prescription.any_items?

    prescription.prescription_items.create!(medication: "Amoxicilina")
    assert prescription.any_items?
  end

  # --- nested attributes ---

  test "nested attributes create prescription items" do
    prescription = Prescription.create!(
      appointment: @appointment,
      prescription_items_attributes: [
        { medication: "Amoxicilina", dosage: "500mg" },
        { medication: "Ibuprofeno", dosage: "400mg" }
      ]
    )
    assert_equal 2, prescription.prescription_items.count
  end

  test "nested attributes reject a row with a blank medication" do
    prescription = Prescription.create!(
      appointment: @appointment,
      prescription_items_attributes: [
        { medication: "Amoxicilina" },
        { medication: "" }
      ]
    )
    assert_equal 1, prescription.prescription_items.count
    assert_equal "Amoxicilina", prescription.prescription_items.first.medication
  end

  test "nested attributes with _destroy remove an item" do
    prescription = Prescription.create!(
      appointment: @appointment,
      prescription_items_attributes: [{ medication: "Amoxicilina" }]
    )
    item = prescription.prescription_items.first

    prescription.update!(
      prescription_items_attributes: [{ id: item.id, _destroy: "1" }]
    )
    assert_equal 0, prescription.prescription_items.count
  end

  # --- dependent: :destroy ---

  test "destroying the prescription destroys its items" do
    prescription = Prescription.create!(
      appointment: @appointment,
      prescription_items_attributes: [
        { medication: "Amoxicilina" },
        { medication: "Ibuprofeno" }
      ]
    )
    item_ids = prescription.prescription_items.pluck(:id)
    assert_equal 2, item_ids.size

    prescription.destroy
    assert_equal 0, PrescriptionItem.where(id: item_ids).count
  end
end
