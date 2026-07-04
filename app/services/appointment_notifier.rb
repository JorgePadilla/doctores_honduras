class AppointmentNotifier
  def self.notify_new_appointment(appointment)
    message = new_appointment_message(appointment)
    notify_staff(appointment, type: "nueva_cita", title: "Nueva cita", message: message)
    notify_patient(appointment, type: "nueva_cita", title: "Cita agendada", message: message)

    AppointmentMailer.confirmation(appointment).deliver_later if appointment.patient_email.present?
  end

  def self.notify_status_change(appointment)
    message = "Cita con #{appointment.patient_name} cambió a #{appointment.status_label}"
    notify_staff(appointment, type: "cambio_estado", title: "Cambio de cita", message: message, except: appointment.created_by)
    notify_patient(appointment, type: "cambio_estado", title: "Cambio en tu cita", message: message)

    AppointmentMailer.status_changed(appointment).deliver_later if appointment.patient_email.present?
  end

  def self.new_appointment_message(appointment)
    "Nueva cita con #{appointment.patient_name} el #{I18n.l(appointment.appointment_date, format: :long)} a las #{appointment.start_time.strftime('%H:%M')}"
  end
  private_class_method :new_appointment_message

  # Doctor + active secretaries (skipping the actor when `except` is given).
  def self.notify_staff(appointment, type:, title:, message:, except: nil)
    url = Rails.application.routes.url_helpers.agenda_appointment_path(appointment)
    doctor_user = appointment.doctor_profile.user

    unless doctor_user == except
      Notification.notify(user: doctor_user, type: type, title: title, message: message, url: url, icon: "calendar_days", notifiable: appointment)
    end

    appointment.doctor_profile.secretary_assignments.active.includes(:user).each do |assignment|
      next if assignment.user == except
      Notification.notify(user: assignment.user, type: type, title: title, message: message, url: url, icon: "calendar_days", notifiable: appointment)
    end
  end
  private_class_method :notify_staff

  # In-app notification for the logged-in patient (email is sent separately).
  def self.notify_patient(appointment, type:, title:, message:)
    return if appointment.patient_user.nil?

    url = Rails.application.routes.url_helpers.paciente_appointment_path(appointment)
    Notification.notify(user: appointment.patient_user, type: type, title: title, message: message, url: url, icon: "calendar_days", notifiable: appointment)
  end
  private_class_method :notify_patient
end
