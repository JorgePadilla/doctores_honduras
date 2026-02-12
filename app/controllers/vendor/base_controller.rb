class Vendor::BaseController < ApplicationController
  include SubscriptionGating

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
end
