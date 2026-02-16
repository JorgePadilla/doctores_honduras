class Agenda::SecretariesController < Agenda::BaseController
  before_action :require_doctor_only

  def index
    @assignments = current_doctor_profile.secretary_assignments.includes(:user)
  end

  def new
    @assignment = current_doctor_profile.secretary_assignments.build
  end

  def create
    email = params[:secretary_assignment][:invited_email]&.strip&.downcase
    user = User.find_by(email: email)

    unless user
      redirect_to new_agenda_secretary_path, alert: "No se encontró un usuario con ese correo electrónico."
      return
    end

    if user == Current.user
      redirect_to new_agenda_secretary_path, alert: "No puedes asignarte como secretaria."
      return
    end

    existing = current_doctor_profile.secretary_assignments.find_by(user: user)

    if existing
      if existing.status == "revoked"
        existing.update!(status: "active", invitation_accepted_at: Time.current)
        redirect_to agenda_secretaries_path, notice: "Secretaria reactivada exitosamente."
      else
        redirect_to new_agenda_secretary_path, alert: "Este usuario ya está asignado como secretaria."
      end
      return
    end

    @assignment = current_doctor_profile.secretary_assignments.build(
      user: user,
      invited_email: email,
      status: "active",
      invitation_accepted_at: Time.current
    )

    if @assignment.save
      redirect_to agenda_secretaries_path, notice: "Secretaria asignada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    assignment = current_doctor_profile.secretary_assignments.find(params[:id])
    assignment.revoke!
    redirect_to agenda_secretaries_path, notice: "Acceso de secretaria revocado."
  end
end
