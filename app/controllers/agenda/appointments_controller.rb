class Agenda::AppointmentsController < Agenda::BaseController
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @view = params[:view] || "week"
    @branches = current_doctor_profile.doctor_branches.ordered

    if @view == "day"
      @appointments = current_doctor_profile.appointments.active.for_date(@date).includes(:doctor_branch).order(:start_time)
    else
      @week_start = @date.beginning_of_week
      @appointments = current_doctor_profile.appointments.active.for_week(@date).includes(:doctor_branch).order(:appointment_date, :start_time)
      @appointments_by_date = @appointments.group_by(&:appointment_date)
    end
  end

  def show
  end

  def new
    @appointment = current_doctor_profile.appointments.build
    @branches = current_doctor_profile.doctor_branches.ordered
  end

  def create
    @appointment = current_doctor_profile.appointments.build(appointment_params)
    @appointment.created_by = Current.user
    @appointment.booking_source = "manual"

    if @appointment.save
      AppointmentNotifier.notify_new_appointment(@appointment)
      redirect_to agenda_appointment_path(@appointment), notice: "Cita creada exitosamente."
    else
      @branches = current_doctor_profile.doctor_branches.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @branches = current_doctor_profile.doctor_branches.ordered
  end

  def update
    old_status = @appointment.status

    if @appointment.update(appointment_params)
      if @appointment.status != old_status
        AppointmentNotifier.notify_status_change(@appointment)
      end
      redirect_to agenda_appointment_path(@appointment), notice: "Cita actualizada exitosamente."
    else
      @branches = current_doctor_profile.doctor_branches.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.update!(status: "cancelada")
    AppointmentNotifier.notify_status_change(@appointment)
    redirect_to agenda_appointments_path, notice: "Cita cancelada."
  end

  private

  def set_appointment
    @appointment = current_doctor_profile.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(
      :doctor_branch_id, :patient_name, :patient_phone, :patient_email,
      :appointment_date, :start_time, :end_time, :status, :reason, :doctor_notes,
      :patient_user_id
    )
  end
end
