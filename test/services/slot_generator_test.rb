require "test_helper"

class SlotGeneratorTest < ActiveSupport::TestCase
  MONDAY = Date.new(2026, 7, 6)

  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc Test", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede Central", address: "Calle 1")
    @branch.ensure_default_schedules!
    @setting = @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
  end

  def generate
    SlotGenerator.new(doctor_branch: @branch, date: MONDAY, doctor_profile: @profile).generate
  end

  def slot_at(slots, start_time)
    slots.find { |s| s[:start_time] == start_time }
  end

  def create_appointment(attrs = {})
    @profile.appointments.create!({
      doctor_branch: @branch,
      patient_name: "Paciente",
      appointment_date: MONDAY,
      start_time: "09:00",
      end_time: "09:30",
      booking_source: "manual"
    }.merge(attrs))
  end

  test "a booked slot becomes unavailable when max_concurrent is 1" do
    create_appointment
    slot = slot_at(generate, "09:00")
    assert_not slot[:available]
  end

  test "a slot stays available until max_concurrent is reached" do
    @branch.update!(max_concurrent: 2)
    create_appointment
    assert slot_at(generate, "09:00")[:available], "one booking under a limit of 2 keeps the slot open"

    create_appointment
    assert_not slot_at(generate, "09:00")[:available], "two bookings fill a limit of 2"
  end

  test "sobrecupo appointments do not reduce slot availability" do
    create_appointment(sobrecupo: true)
    assert slot_at(generate, "09:00")[:available]
  end
end
