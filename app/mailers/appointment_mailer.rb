class AppointmentMailer < ApplicationMailer
  def confirmation(appointment)
    @appointment = appointment
    @doctor = appointment.doctor_profile
    @branch = appointment.doctor_branch

    mail(
      to: appointment.patient_email,
      subject: "Confirmación de cita - Dr. #{@doctor.name} - Doctores Honduras"
    )
  end

  def status_changed(appointment)
    @appointment = appointment
    @doctor = appointment.doctor_profile
    @branch = appointment.doctor_branch

    mail(
      to: appointment.patient_email,
      subject: "Actualización de cita - Dr. #{@doctor.name} - Doctores Honduras"
    )
  end
end
