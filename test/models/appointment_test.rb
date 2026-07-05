require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  # A Monday, so the default Mon-Sat branch schedule (08:00-17:00) applies.
  MONDAY = Date.new(2026, 7, 6)

  setup do
    @user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: @user, name: "Doc Test", department: departments(:one), city: cities(:one))
    @branch = @profile.doctor_branches.create!(name: "Sede Central", address: "Calle 1")
    @branch.ensure_default_schedules!
    @setting = @profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
  end

  def build_appointment(attrs = {})
    @profile.appointments.build({
      doctor_branch: @branch,
      patient_name: "Paciente",
      appointment_date: MONDAY,
      start_time: "09:00",
      end_time: "09:30",
      booking_source: "manual"
    }.merge(attrs))
  end

  # --- C1: configurable duration ---

  test "requested_duration derives end_time from start_time" do
    appt = build_appointment(end_time: nil, requested_duration: 45)
    assert appt.save, appt.errors.full_messages.to_sentence
    assert_equal 45, appt.duration_minutes
    assert_equal "09:45", appt.end_time.strftime("%H:%M")
  end

  test "requested_duration supports 90 minutes" do
    appt = build_appointment(end_time: nil, requested_duration: 90)
    assert appt.save, appt.errors.full_messages.to_sentence
    assert_equal 90, appt.duration_minutes
  end

  test "duration below the 15 minute minimum is invalid" do
    appt = build_appointment(end_time: nil, requested_duration: 10)
    assert_not appt.save
    assert appt.errors[:end_time].any?
  end

  test "explicit start and end times persist their real duration" do
    appt = build_appointment(start_time: "10:00", end_time: "11:00")
    assert appt.save, appt.errors.full_messages.to_sentence
    assert_equal 60, appt.duration_minutes
  end

  # --- C2: concurrency limit ---

  test "second overlapping appointment is rejected when max_concurrent is 1" do
    assert build_appointment.save
    second = build_appointment
    assert_not second.save
    assert second.errors[:start_time].any?
  end

  test "overlapping appointments are allowed up to max_concurrent" do
    @branch.update!(max_concurrent: 2)
    assert build_appointment.save
    assert build_appointment.save, "second concurrent appointment should fit under the limit"

    third = build_appointment
    assert_not third.save, "third concurrent appointment exceeds the limit"
  end

  test "non-overlapping appointments are always allowed" do
    assert build_appointment(start_time: "09:00", end_time: "09:30").save
    assert build_appointment(start_time: "09:30", end_time: "10:00").save
  end

  # --- C3: sobrecupo ---

  test "sobrecupo appointment bypasses the concurrency limit" do
    assert build_appointment.save
    over = build_appointment(sobrecupo: true)
    assert over.save, over.errors.full_messages.to_sentence
    assert over.sobrecupo?
  end

  test "sobrecupo appointments do not consume capacity" do
    over = build_appointment(sobrecupo: true)
    assert over.save
    # A normal appointment in the same slot still fits because the sobrecupo one
    # is not counted against the limit.
    assert build_appointment.save
  end
end
