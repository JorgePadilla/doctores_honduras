class Vendor::BaseController < ApplicationController
  before_action :require_authentication
  before_action :require_vendor_profile

  private

  def current_supplier
    @current_supplier ||= Current.user.supplier
  end
  helper_method :current_supplier

  def require_vendor_profile
    unless Current.user.profile_type == "vendor" && Current.user.supplier.present?
      redirect_to dashboard_path, alert: "Acceso no autorizado."
    end
  end

  def current_subscription_tier
    plan = Current.user.subscription&.subscription_plan
    plan&.tier || "gratis"
  end
  helper_method :current_subscription_tier

  def paid_plan?
    current_subscription_tier != "gratis"
  end
  helper_method :paid_plan?
end
