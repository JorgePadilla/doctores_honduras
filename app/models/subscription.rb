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

    Rails.logger.info("Starting Stripe subscription creation for plan: #{subscription_plan&.name}")

    # Ensure Stripe product and price exist
    if subscription_plan.stripe_price_id.blank?
      Rails.logger.info("Creating Stripe product for plan: #{subscription_plan.name}")
      subscription_plan.create_or_update_stripe_product
    else
      Rails.logger.info("Stripe product already exists for plan: #{subscription_plan.name}")
    end

    # Create or retrieve Stripe customer
    customer = find_or_create_stripe_customer
    Rails.logger.info("Stripe customer: #{customer.id}")

    # Create a Setup Intent to collect payment method
    setup_intent = Stripe::SetupIntent.create({
      customer: customer.id,
      payment_method_types: ['card'],
      usage: 'off_session',
      metadata: {
        user_id: user.id,
        plan_id: subscription_plan.id
      }
    })

    Rails.logger.info("Setup Intent created: #{setup_intent.id}, status: #{setup_intent.status}")

    # Return the Setup Intent client secret for frontend
    setup_intent.client_secret
  end

  def complete_stripe_subscription(payment_method_id)
    return unless stripe_customer_id.present?

    # Attach payment method to customer
    Stripe::PaymentMethod.attach(
      payment_method_id,
      { customer: stripe_customer_id }
    )

    # Set as default payment method
    Stripe::Customer.update(
      stripe_customer_id,
      { invoice_settings: { default_payment_method: payment_method_id } }
    )

    # Now create the subscription
    stripe_subscription = Stripe::Subscription.create({
      customer: stripe_customer_id,
      items: [{ price: subscription_plan.stripe_price_id }],
      expand: ['latest_invoice.payment_intent'],
    })

    # Update subscription with Stripe data
    update(
      stripe_subscription_id: stripe_subscription.id,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    # Return client secret if needed for immediate payment
    if stripe_subscription.latest_invoice.payment_intent
      stripe_subscription.latest_invoice.payment_intent.client_secret
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
      # Create new customer - use email as name
      customer_data = {
        email: user.email,
        name: user.email,  # Use email as name since User model doesn't have name attribute
        metadata: { user_id: user.id }
      }

      customer = Stripe::Customer.create(customer_data)

      # Save the Stripe customer ID
      update(stripe_customer_id: customer.id)

      customer
    end
  end
end
