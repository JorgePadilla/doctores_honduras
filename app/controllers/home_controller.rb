class HomeController < ApplicationController
  skip_before_action :require_authentication, only: [:index]

  def index
    redirect_to_onboarding_if_needed
  end

  private

  def redirect_to_onboarding_if_needed
    return unless authenticated?
    return if Current.user.onboarding_completed?
    redirect_to onboarding_profile_type_path
  end
end
