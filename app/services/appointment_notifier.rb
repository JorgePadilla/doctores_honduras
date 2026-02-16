class AppointmentNotifier
  def self.notify_new_appointment(appointment)
    doctor_user = appointment.doctor_profile.user

    create_notification(
      user: doctor_user,
      appointment: appointment,
      type: "nueva_cita",
      message: "Nueva cita con #{appointment.patient_name} el #{I18n.l(appointment.appointment_date, format: :long)} a las #{appointment.start_time.strftime('%H:%M')}"
    )

    appointment.doctor_profile.secretary_assignments.active.includes(:user).each do |assignment|
      create_notification(
        user: assignment.user,
        appointment: appointment,
        type: "nueva_cita",
        message: "Nueva cita con #{appointment.patient_name} el #{I18n.l(appointment.appointment_date, format: :long)} a las #{appointment.start_time.strftime('%H:%M')}"
      )
    end

    if appointment.patient_email.present?
      AppointmentMailer.confirmation(appointment).deliver_later
    end
  end

  def self.notify_status_change(appointment)
    doctor_user = appointment.doctor_profile.user

    create_notification(
      user: doctor_user,
      appointment: appointment,
      type: "cambio_estado",
      message: "Cita con #{appointment.patient_name} cambió a #{appointment.status_label}"
    )

    appointment.doctor_profile.secretary_assignments.active.includes(:user).each do |assignment|
      next if assignment.user == appointment.created_by
      create_notification(
        user: assignment.user,
        appointment: appointment,
        type: "cambio_estado",
        message: "Cita con #{appointment.patient_name} cambió a #{appointment.status_label}"
      )
    end

    if appointment.patient_email.present?
      AppointmentMailer.status_changed(appointment).deliver_later
    end
  end

  def self.create_notification(user:, appointment:, type:, message:)
    AppointmentNotification.create!(
      user: user,
      appointment: appointment,
      notification_type: type,
      message: message
    )
  end
  private_class_method :create_notification
end
