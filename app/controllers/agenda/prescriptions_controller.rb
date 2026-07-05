class Agenda::PrescriptionsController < Agenda::BaseController
  before_action :require_elite
  before_action :set_appointment

  def show
    @prescription = @appointment.prescription
    if @prescription.nil? || !@prescription.any_items?
      redirect_to edit_agenda_appointment_prescription_path(@appointment)
      return
    end
    render layout: "print"
  end

  def edit
    @prescription = @appointment.prescription || @appointment.build_prescription
    @prescription.prescription_items.build if @prescription.prescription_items.empty?
  end

  def update
    @prescription = @appointment.prescription || @appointment.build_prescription
    if @prescription.update(prescription_params)
      redirect_to agenda_appointment_path(@appointment), notice: "Receta guardada."
    else
      @prescription.prescription_items.build if @prescription.prescription_items.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = current_doctor_profile.appointments.find(params[:appointment_id])
  end

  def prescription_params
    params.require(:prescription).permit(
      :instructions,
      prescription_items_attributes: [ :id, :medication, :dosage, :frequency, :duration, :_destroy ]
    )
  end
end
