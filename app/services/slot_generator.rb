class SlotGenerator
  def initialize(doctor_branch:, date:, doctor_profile:)
    @branch = doctor_branch
    @date = date
    @profile = doctor_profile
    @setting = doctor_profile.agenda_setting || doctor_profile.build_agenda_setting
  end

  def generate
    @branch.ensure_default_schedules!

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

  # C2: a slot stays available while the number of overlapping appointments is
  # below this consultorio's max_concurrent limit. Sobrecupo (C3) appointments
  # are excluded from the count since they don't consume capacity.
  def slot_available?(start_time, end_time)
    occupancy = existing_appointments.count do |appt|
      appt.start_time < end_time && appt.end_time > start_time
    end
    occupancy < max_concurrent
  end

  def max_concurrent
    @max_concurrent ||= @branch.max_concurrent || 1
  end

  def existing_appointments
    @existing_appointments ||= Appointment.active
      .for_branch(@branch)
      .for_date(@date)
      .where(sobrecupo: false)
      .select(:start_time, :end_time)
      .to_a
  end
end
