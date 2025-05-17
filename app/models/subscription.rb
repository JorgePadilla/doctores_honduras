class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan, optional: true
  
  # Campos sugeridos:
  # - plan_name (string)
  # - status (string) - 'active', 'canceled', 'past_due'
  # - current_period_start (datetime)
  # - current_period_end (datetime)
  # - stripe_subscription_id (string)
  # - stripe_customer_id (string)
  
  validates :user_id, presence: true, uniqueness: true
  
  def active?
    status == 'active' && current_period_end > Time.current
  end
  
  def days_remaining
    return 0 unless active?
    ((current_period_end - Time.current) / 1.day).to_i
  end
  
  def cancel_at_period_end?
    status == 'active' && cancel_at.present? && cancel_at <= current_period_end
  end
end
