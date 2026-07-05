module AgendaAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_doctor_profile, :acting_as_secretary?,
                  :current_doctor_tier, :current_doctor_elite?
  end

  private

  def current_doctor_profile
    @current_doctor_profile ||= resolve_doctor_profile
  end

  # Tier del médico dueño de la agenda (una secretaria hereda el del doctor).
  def current_doctor_tier
    current_doctor_profile&.user&.subscription&.subscription_plan&.tier || "gratis"
  end

  def current_doctor_elite?
    current_doctor_tier == "elite"
  end

  # Gate para el Expediente Clínico Digital (función exclusiva de Elite).
  def require_elite
    unless current_doctor_elite?
      redirect_to agenda_patients_path,
        alert: "El Expediente Clínico Digital está disponible solo en el plan Elite."
    end
  end

  def resolve_doctor_profile
    if Current.user.profile_type == "doctor" && Current.user.doctor_profile.present?
      Current.user.doctor_profile
    elsif Current.user.secretary?
      Current.user.secretary_assignments.active.first&.doctor_profile
    end
  end

  def acting_as_secretary?
    Current.user.profile_type != "doctor" && Current.user.secretary?
  end

  def require_agenda_access
    unless current_doctor_profile
      redirect_to dashboard_path, alert: "No tienes acceso a la agenda."
      return
    end

    tier = current_doctor_profile.user.subscription&.subscription_plan&.tier || "gratis"
    if tier == "gratis"
      redirect_to dashboard_path, alert: "Necesitas un plan Profesional o Elite para acceder a la agenda."
    end
  end

  def require_doctor_or_secretary
    unless current_doctor_profile
      redirect_to dashboard_path, alert: "No tienes acceso a esta sección."
    end
  end

  def require_doctor_only
    unless Current.user.profile_type == "doctor" && Current.user.doctor_profile.present?
      redirect_to agenda_appointments_path, alert: "Solo el doctor puede realizar esta acción."
    end
  end
end
