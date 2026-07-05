class Agenda::SettingsController < Agenda::BaseController
  def show
    @setting = current_doctor_profile.agenda_setting || current_doctor_profile.build_agenda_setting
    @tier = current_doctor_profile.user.subscription&.subscription_plan&.tier || "gratis"
  end

  def update
    @setting = current_doctor_profile.agenda_setting || current_doctor_profile.build_agenda_setting
    @tier = current_doctor_profile.user.subscription&.subscription_plan&.tier || "gratis"

    permitted = setting_params
    # Only elite can toggle public booking
    permitted.delete(:public_booking_enabled) unless @tier == "elite"

    if @setting.update(permitted)
      redirect_to agenda_settings_path, notice: "Configuración guardada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:doctor_agenda_setting).permit(:appointment_duration, :buffer_minutes, :public_booking_enabled)
  end
end
