class BookingsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_doctor_profile
  before_action :require_public_booking

  def new
    @branches = @doctor_profile.doctor_branches.ordered
    @appointment = @doctor_profile.appointments.build

    if Current.user&.profile_type == "paciente" && Current.user.patient_profile
      patient = Current.user.patient_profile
      @appointment.patient_name = patient.name
      @appointment.patient_phone = patient.phone
      @appointment.patient_email = Current.user.email
    end
  end

  def create
    @appointment = @doctor_profile.appointments.build(booking_params)
    @appointment.booking_source = "public_booking"
    @appointment.created_by = Current.user if Current.user

    if Current.user&.profile_type == "paciente"
      @appointment.patient_user_id = Current.user.id
    end

    if @appointment.save
      AppointmentNotifier.notify_new_appointment(@appointment)
      redirect_to doctor_path(@doctor_profile), notice: "Cita reservada exitosamente. Recibirás un correo de confirmación."
    else
      @branches = @doctor_profile.doctor_branches.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def slots
    branch = @doctor_profile.doctor_branches.find(params[:branch_id])
    date = Date.parse(params[:date])

    slots = SlotGenerator.new(
      doctor_branch: branch,
      date: date,
      doctor_profile: @doctor_profile
    ).available_slots

    render json: slots
  rescue ArgumentError, ActiveRecord::RecordNotFound
    render json: [], status: :unprocessable_entity
  end

  private

  def set_doctor_profile
    doctor = DoctorProfile.find(params[:doctor_id])
    @doctor_profile = doctor
  end

  def require_public_booking
    tier = @doctor_profile.user.subscription&.subscription_plan&.tier || "gratis"
    setting = @doctor_profile.agenda_setting

    unless tier == "elite" && setting&.public_booking_enabled
      redirect_to doctor_path(@doctor_profile), alert: "La reserva en línea no está disponible para este doctor."
    end
  end

  def booking_params
    params.require(:appointment).permit(
      :doctor_branch_id, :patient_name, :patient_phone, :patient_email,
      :appointment_date, :start_time, :end_time, :reason
    )
  end
end
