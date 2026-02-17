class ProfilesController < ApplicationController
  include SubscriptionGating

  before_action :require_authentication
  before_action :set_user

  def show
    case @user.profile_type
    when 'doctor'
      @doctor_profile = DoctorProfile.includes(
        :specialty, :subspecialty, :city, :department, :services,
        doctor_branches: [:department, :city, :branch_schedules],
        doctor_educations: [],
        doctor_certifications: []
      ).find_by(user_id: @user.id)
      redirect_to new_profile_path unless @doctor_profile
    when 'hospital', 'clinic'
      @establishment = @user.establishments.first
      redirect_to dashboard_path unless @establishment
    when 'vendor'
      redirect_to vendor_profile_path
      return
    else
      redirect_to new_profile_path
    end
  end

  def new
    @doctor_profile = DoctorProfile.new
    @specialties = Specialty.order(:name)
    @subspecialties = []
    @departments = Department.order(:name)
    @cities = City.order(:name)
  end

  def create
    @doctor_profile = DoctorProfile.new(doctor_profile_params)
    @doctor_profile.user = @user

    @user.update(profile_type: 'doctor') if @user.profile_type.blank?

    if @doctor_profile.save
      flash[:success] = 'Perfil de doctor creado exitosamente.'
      redirect_to profile_path
    else
      @specialties = Specialty.order(:name)
      @subspecialties = []
      @departments = Department.order(:name)
      @cities = City.order(:name)
      flash.now[:alert] = 'Error al crear el perfil. Por favor verifica los campos.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @doctor_profile = DoctorProfile.includes(
      :services,
      doctor_branches: [:department, :city, :branch_schedules],
      doctor_educations: [],
      doctor_certifications: []
    ).find_by(user_id: @user.id)

    redirect_to new_profile_path and return unless @doctor_profile

    @specialties = Specialty.order(:name)
    @subspecialties = @doctor_profile.specialty&.subspecialties || []
    @departments = Department.order(:name)
    @cities = City.order(:name)

    # Build empty nested records for the form if none exist
    @doctor_profile.doctor_branches.build if @doctor_profile.doctor_branches.empty?
    @doctor_profile.doctor_educations.build if @doctor_profile.doctor_educations.empty?
    @doctor_profile.doctor_certifications.build if @doctor_profile.doctor_certifications.empty?
  end

  def update
    @doctor_profile = @user.doctor_profile

    filtered_params = doctor_profile_params
    filtered_params = strip_paid_branch_fields(filtered_params) unless paid_plan?

    if @doctor_profile.update(filtered_params)
      flash[:success] = 'Perfil actualizado exitosamente.'
      redirect_to profile_path
    else
      @specialties = Specialty.order(:name)
      @subspecialties = @doctor_profile.specialty&.subspecialties || []
      @departments = Department.order(:name)
      @cities = City.order(:name)
      @doctor_profile.doctor_branches.build if @doctor_profile.doctor_branches.empty?
      @doctor_profile.doctor_educations.build if @doctor_profile.doctor_educations.empty?
      @doctor_profile.doctor_certifications.build if @doctor_profile.doctor_certifications.empty?
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
      :prefix, :name, :specialty_id, :subspecialty_id, :description, :website,
      :medical_license, :image_url, :department_id, :city_id, :image_file,
      :fecha_de_nacimiento, :numero_de_identidad, :correo_personal,
      :facebook_url, :instagram_url, :twitter_url, :linkedin_url,
      :tiktok_url, :youtube_url,
      languages: [],
      service_ids: [],
      doctor_branches_attributes: [
        :id, :name, :address, :department_id, :city_id, :map_link,
        :phone, :position, :_destroy,
        branch_schedules_attributes: [
          :id, :day_of_week, :opens_at, :closes_at, :_destroy
        ]
      ],
      doctor_educations_attributes: [
        :id, :institution, :degree, :graduation_year, :position, :_destroy
      ],
      doctor_certifications_attributes: [
        :id, :name, :institution, :year, :position, :_destroy
      ]
    )
  end

  def strip_paid_branch_fields(permitted_params)
    if permitted_params[:doctor_branches_attributes].present?
      # Count non-destroyed branches to enforce free plan limit of 1
      existing_count = @doctor_profile.doctor_branches.count
      new_count = 0

      permitted_params[:doctor_branches_attributes].each do |_key, branch|
        next unless branch.is_a?(ActionController::Parameters) || branch.is_a?(Hash)

        # Strip paid-only fields
        branch.delete(:phone)
        branch.delete(:branch_schedules_attributes)

        # Count new branches (no id = new record, not marked for destroy)
        is_new = branch[:id].blank?
        is_destroy = branch[:_destroy] == "1" || branch[:_destroy] == true
        new_count += 1 if is_new && !is_destroy
      end

      # If adding new branches would exceed the free limit of 1, remove extras
      max_allowed = 1
      destroys = permitted_params[:doctor_branches_attributes].count { |_k, b| b.is_a?(Hash) || b.is_a?(ActionController::Parameters) ? (b[:_destroy] == "1" || b[:_destroy] == true) : false }
      total_after = existing_count - destroys + new_count

      if total_after > max_allowed
        excess = total_after - max_allowed
        permitted_params[:doctor_branches_attributes].reverse_each do |_key, branch|
          next unless branch.is_a?(ActionController::Parameters) || branch.is_a?(Hash)
          break if excess <= 0
          if branch[:id].blank? && branch[:_destroy] != "1"
            branch[:_destroy] = "1"
            excess -= 1
          end
        end
      end
    end
    permitted_params
  end
end
