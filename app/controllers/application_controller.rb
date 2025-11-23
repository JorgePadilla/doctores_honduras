class ApplicationController < ActionController::Base
  include Authentication
  include Internationalization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :ensure_subscription, unless: -> { skip_subscription_check? }

  private

  def ensure_subscription
    return unless Current.user && Current.user.onboarding_completed?
    return if Current.user.subscription.present?

    # Redirect to plan selection if user has completed onboarding but has no subscription
    redirect_to onboarding_plan_selection_path, alert: "Por favor seleccione un plan para continuar."
  end

  def skip_subscription_check?
    # Skip subscription check for onboarding, authentication, and static pages
    controller_name.in?(%w[onboarding sessions registrations passwords confirmations]) ||
    action_name.in?(%w[plan_selection plan_confirmation profile_setup profile_confirmation]) ||
    request.path == root_path
  end
end
