class Paciente::ProfilesController < Paciente::BaseController
  def show
    @patient_profile = Current.user.patient_profile
    # Un paciente puede no tener ficha demográfica todavía; lo mandamos a crearla
    # en vez de reventar la vista.
    redirect_to edit_paciente_profile_path, notice: "Completá tu perfil para continuar." and return unless @patient_profile
  end

  def edit
    @patient_profile = Current.user.patient_profile || Current.user.build_patient_profile
    @patient_profile.country_id ||= default_country_id
    load_location_options
  end

  def update
    @patient_profile = Current.user.patient_profile || Current.user.build_patient_profile
    @patient_profile.assign_attributes(patient_profile_params)
    new_email = params[:email].to_s.strip
    Current.user.email = new_email if new_email.present?

    if Current.user.valid? && @patient_profile.valid?
      Current.user.save!
      @patient_profile.save!
      redirect_to paciente_profile_path, notice: "Perfil actualizado exitosamente."
    else
      Current.user.errors.full_messages.each { |m| @patient_profile.errors.add(:base, "Correo: #{m}") }
      @patient_profile.country_id ||= default_country_id
      load_location_options
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def default_country_id
    Country.order(:name).first&.id
  end

  def load_location_options
    @countries = Country.order(:name)
    @departments = @patient_profile.country_id ? Department.where(country_id: @patient_profile.country_id).order(:name) : Department.none
    @cities = @patient_profile.department_id ? City.where(department_id: @patient_profile.department_id).order(:name) : City.none
  end

  def patient_profile_params
    params.require(:patient_profile).permit(:name, :identity_document, :phone, :date_of_birth, :country_id, :department_id, :city_id)
  end
end
