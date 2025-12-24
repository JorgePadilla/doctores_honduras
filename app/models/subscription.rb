class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan, optional: true
  
  # Campos:
  # - plan_name (string)
  # - status (string) - 'active', 'canceled', 'past_due'
  # - current_period_start (datetime)
  # - current_period_end (datetime)
  # - stripe_subscription_id (string)
  # - stripe_customer_id (string)
  # - cancel_at (datetime)
  
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
  
  # Stripe integration methods
  def create_stripe_subscription
    return if stripe_subscription_id.present?
    
    # Create or retrieve Stripe customer
    customer = find_or_create_stripe_customer
    
    # Create Stripe subscription
    stripe_subscription = Stripe::Subscription.create({
      customer: customer.id,
      items: [{ price: subscription_plan.stripe_price_id }],
      expand: ['latest_invoice.payment_intent'],
    })
    
    # Update subscription with Stripe data
    update(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: customer.id,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )
    
    # Return client secret for payment confirmation
    if stripe_subscription.latest_invoice.payment_intent
      return stripe_subscription.latest_invoice.payment_intent.client_secret
    end
  end
  
  def cancel_stripe_subscription
    return unless stripe_subscription_id.present?
    
    # Cancel at period end
    stripe_subscription = Stripe::Subscription.update(
      stripe_subscription_id,
      { cancel_at_period_end: true }
    )
    
    # Update local subscription
    update(
      status: 'canceled',
      cancel_at: Time.at(stripe_subscription.cancel_at || stripe_subscription.current_period_end)
    )
  end
  
  def reactivate_stripe_subscription
    return unless stripe_subscription_id.present? && status == 'canceled'
    
    # Remove cancellation
    stripe_subscription = Stripe::Subscription.update(
      stripe_subscription_id,
      { cancel_at_period_end: false }
    )
    
    # Update local subscription
    update(
      status: stripe_subscription.status,
      cancel_at: nil
    )
  end
  
  private
  
  def find_or_create_stripe_customer
    if stripe_customer_id.present?
      # Return existing customer
      Stripe::Customer.retrieve(stripe_customer_id)
    else
      # Create new customer
      Stripe::Customer.create({
        email: user.email,
        name: user.name,
        metadata: { user_id: user.id }
      })
    end
  end
end
