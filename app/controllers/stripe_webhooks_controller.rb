class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.dig(:stripe, :webhook_secret)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      Rails.logger.error("Invalid Stripe webhook payload: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      Rails.logger.error("Invalid Stripe webhook signature: #{e.message}")
      return head :bad_request
    end

    # Handle the event
    case event.type
    when 'setup_intent.succeeded'
      handle_setup_intent_succeeded(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_payment_succeeded(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    else
      Rails.logger.info("Unhandled Stripe event type: #{event.type}")
    end

    head :ok
  end

  private

  def handle_setup_intent_succeeded(setup_intent)
    # Find the subscription by user ID from metadata
    user_id = setup_intent.metadata['user_id']
    plan_id = setup_intent.metadata['plan_id']

    return unless user_id && plan_id

    user = User.find_by(id: user_id)
    return unless user

    subscription = user.subscription
    return unless subscription

    # Complete the subscription creation with the payment method
    payment_method_id = setup_intent.payment_method
    if payment_method_id
      subscription.complete_stripe_subscription(payment_method_id)
      Rails.logger.info("Subscription completed for user: #{user_id} with payment method: #{payment_method_id}")
    else
      Rails.logger.error("No payment method found in setup intent: #{setup_intent.id}")
    end
  end

  def handle_invoice_payment_succeeded(invoice)
    # Find subscription by Stripe subscription ID
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    # Update subscription status
    subscription.update(
      status: 'active',
      current_period_start: Time.at(invoice.period_start),
      current_period_end: Time.at(invoice.period_end)
    )

    # Mark user onboarding as completed if not already
    user = subscription.user
    unless user.onboarding_completed?
      user.update(onboarding_completed: true)
    end

    Rails.logger.info("Payment succeeded for subscription: #{subscription.id}")
  end

  def handle_invoice_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update(status: 'past_due')
    Rails.logger.warn("Payment failed for subscription: #{subscription.id}")
  end

  def handle_subscription_updated(subscription)
    local_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)
    return unless local_subscription

    local_subscription.update(
      status: subscription.status,
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end),
      cancel_at: subscription.cancel_at ? Time.at(subscription.cancel_at) : nil
    )
  end

  def handle_subscription_deleted(subscription)
    local_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)
    return unless local_subscription

    local_subscription.update(status: 'canceled')
  end
end