module SubscriptionGating
  extend ActiveSupport::Concern

  included do
    helper_method :current_subscription_tier, :paid_plan?
  end

  private

  def current_subscription_tier
    plan = Current.user.subscription&.subscription_plan
    plan&.tier || "gratis"
  end

  def paid_plan?
    current_subscription_tier != "gratis"
  end
end
