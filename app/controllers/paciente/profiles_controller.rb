class Paciente::ProfilesController < Paciente::BaseController
  def show
    @patient_profile = Current.user.patient_profile
  end

  def edit
    @patient_profile = Current.user.patient_profile
    @departments = Department.order(:name)
    @cities = City.order(:name)
  end

  def update
    @patient_profile = Current.user.patient_profile

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
    params.require(:patient_profile).permit(:name, :phone, :date_of_birth, :department_id, :city_id)
  end
end
