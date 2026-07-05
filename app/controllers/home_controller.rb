class HomeController < ApplicationController
  skip_before_action :require_authentication, only: [ :index ]

  def index
    redirect_to_onboarding_if_needed
    return if performed?

    @doctor_count = DoctorProfile.count
    @specialty_count = Specialty.count
    @department_count = Department.count
    @placeholder_specialties = Specialty.order(:name).limit(8).pluck(:name)
  end

  private

  def redirect_to_onboarding_if_needed
    return unless authenticated?
    return if Current.user.onboarding_completed?
    redirect_to onboarding_profile_type_path
  end
end
