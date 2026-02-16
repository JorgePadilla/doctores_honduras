class Paciente::BaseController < ApplicationController
  before_action :require_authentication
  before_action :require_paciente

  private

  def require_paciente
    unless Current.user.profile_type == "paciente"
      redirect_to dashboard_path, alert: "Acceso restringido a pacientes."
    end
  end
end
