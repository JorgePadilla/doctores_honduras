class SlotGenerator
  def initialize(doctor_branch:, date:, doctor_profile:)
    @branch = doctor_branch
    @date = date
    @profile = doctor_profile
    @setting = doctor_profile.agenda_setting || doctor_profile.build_agenda_setting
  end

  def generate
    schedule = @branch.branch_schedules.find_by(day_of_week: @date.wday)
    return [] unless schedule

    duration = @setting.appointment_duration
    buffer = @setting.buffer_minutes
    step = duration + buffer

    slots = []
    current = schedule.opens_at

    while current + duration.minutes <= schedule.closes_at
      slot_start = current
      slot_end = current + duration.minutes

      slots << {
        start_time: slot_start.strftime("%H:%M"),
        end_time: slot_end.strftime("%H:%M"),
        available: slot_available?(slot_start, slot_end)
      }

      current += step.minutes
    end

    slots
  end

  def available_slots
    generate.select { |s| s[:available] }
  end

  private

  def slot_available?(start_time, end_time)
    !existing_appointments.any? do |appt|
      appt.start_time < end_time && appt.end_time > start_time
    end
  end

  def existing_appointments
    @existing_appointments ||= Appointment.active
      .for_branch(@branch)
      .for_date(@date)
      .select(:start_time, :end_time)
      .to_a
  end
end
