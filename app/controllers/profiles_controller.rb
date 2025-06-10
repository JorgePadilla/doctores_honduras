class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_user

  def show
    case @user.profile_type
    when 'doctor'
      @doctor_profile = @user.doctor_profile
      redirect_to new_profile_path unless @doctor_profile
    when 'hospital', 'clinic'
      # Handle hospital/clinic profiles here when implemented
      redirect_to dashboard_path
    else
      # If user doesn't have profile type set, allow them to create a doctor profile
      redirect_to new_profile_path
    end
  end

  def new
    # Allow users to create doctor profiles even if they don't have profile_type set
    @doctor_profile = DoctorProfile.new
  end

  def create
    @doctor_profile = DoctorProfile.new(doctor_profile_params)
    @doctor_profile.user = @user

    # Set user's profile type to doctor if not already set
    @user.update(profile_type: 'doctor') if @user.profile_type.blank?

    if @doctor_profile.save
      redirect_to profile_path, notice: 'Perfil de doctor creado exitosamente.'
    else
      flash.now[:alert] = 'Error al crear el perfil. Por favor verifica los campos.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @doctor_profile = @user.doctor_profile
    redirect_to new_profile_path unless @doctor_profile
  end

  def update
    @doctor_profile = @user.doctor_profile

    if @doctor_profile.update(doctor_profile_params)
      redirect_to profile_path, notice: 'Perfil actualizado exitosamente.'
    else
      flash.now[:alert] = 'Error al actualizar el perfil. Por favor verifica los campos.'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def doctor_profile_params
    params.require(:doctor_profile).permit(
      :name,
      :specialization,
      :subspecialty,
      :description,
      :address,
      :city,
      :state,
      :website,
      :image_url,
      :medical_license
    )
  end
end