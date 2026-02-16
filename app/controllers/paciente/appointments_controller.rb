class Paciente::AppointmentsController < Paciente::BaseController
  def index
    appointments = Current.user.patient_appointments.includes(doctor_profile: :specialty, doctor_branch: [])
    @upcoming = appointments.active.upcoming.order(:appointment_date, :start_time)
    @past = appointments.where("appointment_date < ? OR (appointment_date = ? AND end_time < ?)", Date.current, Date.current, Time.current)
                        .order(appointment_date: :desc, start_time: :desc)
  end

  def show
    @appointment = Current.user.patient_appointments.find(params[:id])
  end
end
