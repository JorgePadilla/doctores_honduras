class Paciente::ProfilesController < Paciente::BaseController
  def show
    @patient_profile = Current.user.patient_profile
    # Un paciente puede no tener ficha demográfica todavía; lo mandamos a crearla
    # en vez de reventar la vista.
    redirect_to edit_paciente_profile_path, notice: "Completá tu perfil para continuar." and return unless @patient_profile
  end

  def edit
    @patient_profile = Current.user.patient_profile || Current.user.build_patient_profile
    @departments = Department.order(:name)
    @cities = City.order(:name)
  end

  def update
    @patient_profile = Current.user.patient_profile || Current.user.build_patient_profile

    if @patient_profile.update(patient_profile_params)
      redirect_to paciente_profile_path, notice: "Perfil actualizado exitosamente."
    else
      @departments = Department.order(:name)
      @cities = City.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def patient_profile_params
    params.require(:patient_profile).permit(:name, :identity_document, :phone, :date_of_birth, :department_id, :city_id)
  end
end
