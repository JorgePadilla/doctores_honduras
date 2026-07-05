class Agenda::EncountersController < Agenda::BaseController
  before_action :require_elite
  before_action :set_appointment

  def edit
    @encounter = @appointment.encounter || @appointment.build_encounter
  end

  def update
    @encounter = @appointment.encounter || @appointment.build_encounter
    if @encounter.update(encounter_params)
      redirect_to agenda_appointment_path(@appointment), notice: "Consulta documentada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = current_doctor_profile.appointments.find(params[:appointment_id])
  end

  def encounter_params
    params.require(:encounter).permit(:evolution_note, :blood_pressure, :heart_rate, :temperature, :respiratory_rate, :oxygen_saturation, :weight, :height)
  end
end
