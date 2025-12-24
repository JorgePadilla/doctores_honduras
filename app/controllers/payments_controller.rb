class PaymentsController < ApplicationController
  before_action :require_authentication
  before_action :require_payment_client_secret
  
  def show
    @client_secret = session[:payment_client_secret]
    @subscription = current_user.subscription
    @plan = @subscription&.subscription_plan
  end
  
  private
  
  def require_payment_client_secret
    unless session[:payment_client_secret].present?
      redirect_to dashboard_path, alert: "No hay pagos pendientes."
    end
  end
end
