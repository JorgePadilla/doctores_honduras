class OnboardingController < ApplicationController
  before_action :require_authentication
  before_action :redirect_if_onboarding_completed

  def profile_type_selection
    # Step 1: Choose profile type (Doctor, Hospital/Clinic, Vendor, or Viewer)
  end

  def save_profile_type
    profile_type = params[:profile_type]

    unless %w[doctor hospital clinic vendor paciente].include?(profile_type)
      # Viewer — just mark onboarding done and go to doctors directory
      current_user.update(onboarding_completed: true)
      redirect_to doctors_path, notice: "¡Bienvenido a Doctores Honduras!"
      return
    end

    current_user.update(profile_type: profile_type)
    redirect_to onboarding_basic_info_path
  end

  def basic_info
    # Step 2: Minimal profile form based on profile type
    @profile_type = current_user.profile_type

    if @profile_type.blank?
      redirect_to onboarding_profile_type_path
      return
    end

    case @profile_type
    when "doctor"
      @doctor_profile = current_user.doctor_profile || current_user.build_doctor_profile
      @specialties = Specialty.order(:name)
      @departments = Department.order(:name)
      @cities = City.order(:name)
    when "hospital", "clinic"
      @establishment = current_user.establishments.first || current_user.establishments.build(est_type: @profile_type == "clinic" ? "Clínica" : "Hospital")
      @departments = Department.order(:name)
      @cities = City.order(:name)
    when "vendor"
      @supplier = current_user.supplier || current_user.build_supplier
      @departments = Department.order(:name)
      @cities = City.order(:name)
    when "paciente"
      @patient_profile = current_user.patient_profile || current_user.build_patient_profile
      @departments = Department.order(:name)
      @cities = City.order(:name)
    end
  end

  def complete
    @profile_type = current_user.profile_type

    case @profile_type
    when "doctor"
      @doctor_profile = current_user.doctor_profile || current_user.build_doctor_profile
      @doctor_profile.assign_attributes(doctor_profile_params)
      if @doctor_profile.save
        assign_free_plan_and_finish
      else
        @specialties = Specialty.order(:name)
        @departments = Department.order(:name)
        @cities = City.order(:name)
        render :basic_info, status: :unprocessable_entity
      end
    when "hospital", "clinic"
      @establishment = current_user.establishments.first || current_user.establishments.build
      @establishment.assign_attributes(establishment_params)
      @establishment.est_type = @profile_type == "clinic" ? "Clínica" : "Hospital"
      if @establishment.save
        assign_free_plan_and_finish
      else
        @departments = Department.order(:name)
        @cities = City.order(:name)
        render :basic_info, status: :unprocessable_entity
      end
    when "vendor"
      @supplier = current_user.supplier || current_user.build_supplier
      @supplier.assign_attributes(supplier_params)
      if @supplier.save
        assign_free_plan_and_finish
      else
        @departments = Department.order(:name)
        @cities = City.order(:name)
        render :basic_info, status: :unprocessable_entity
      end
    when "paciente"
      @patient_profile = current_user.patient_profile || current_user.build_patient_profile
      @patient_profile.assign_attributes(patient_profile_params)
      if @patient_profile.save
        assign_free_plan_and_finish
      else
        @departments = Department.order(:name)
        @cities = City.order(:name)
        render :basic_info, status: :unprocessable_entity
      end
    else
      redirect_to onboarding_profile_type_path, alert: "Tipo de perfil no válido."
    end
  end

  private

  def current_user
    Current.user
  end

  def redirect_if_onboarding_completed
    redirect_to dashboard_path if current_user&.onboarding_completed
  end

  def assign_free_plan_and_finish
    # Find the free plan for this profile type
    plan_profile = current_user.profile_type == "clinic" ? "hospital" : current_user.profile_type
    free_plan = SubscriptionPlan.find_by(profile_type: plan_profile, tier: "gratis")

    if free_plan
      subscription = current_user.subscription || current_user.build_subscription
      subscription.subscription_plan = free_plan
      subscription.plan_name = free_plan.name
      subscription.status = "active"
      subscription.current_period_start = Time.current
      subscription.current_period_end = 100.years.from_now
      subscription.save!
    end

    current_user.update!(onboarding_completed: true)
    redirect_to dashboard_path, notice: "¡Configuración completada! Bienvenido a Doctores Honduras."
  end

  def doctor_profile_params
    params.require(:doctor_profile).permit(:name, :specialty_id, :department_id, :city_id)
  end

  def establishment_params
    params.require(:establishment).permit(:name, :address, :phone, :department_id, :city_id)
  end

  def supplier_params
    params.require(:supplier).permit(:name, :phone, :category, :department_id, :city_id)
  end

  def patient_profile_params
    params.require(:patient_profile).permit(:name, :phone, :date_of_birth, :department_id, :city_id)
  end
end
