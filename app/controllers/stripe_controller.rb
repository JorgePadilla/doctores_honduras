class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]
  before_action :require_authentication, except: [ :webhook ]

  # Endpoint for creating a checkout session
  def create_checkout_session
    @user = Current.user
    plan_id = params[:plan_id]

    # Verify the plan exists
    @plan = SubscriptionPlan.find_by(id: plan_id)
    if @plan.nil?
      redirect_to settings_subscription_path, alert: "El plan seleccionado no existe."
      return
    end

    # Ensure the plan has a Stripe price ID
    if @plan.stripe_price_id.blank?
      # Create the product and price in Stripe if it doesn't exist
      begin
        @plan.create_or_update_stripe_product
      rescue Stripe::StripeError => e
        redirect_to settings_subscription_path, alert: "Error al crear el producto en Stripe: #{e.message}"
        return
      end
    end

    # Create or get the user's subscription
    subscription = @user.subscription || @user.build_subscription
    subscription.subscription_plan = @plan

    # Create a checkout session
    begin
      session = Stripe::Checkout::Session.create({
        payment_method_types: [ "card" ],
        line_items: [ {
          price: @plan.stripe_price_id,
          quantity: 1
        } ],
        mode: "subscription",
        success_url: stripe_success_url(plan_id: @plan.id),
        cancel_url: stripe_cancel_url,
        customer_email: @user.email,
        metadata: {
          user_id: @user.id,
          plan_id: @plan.id
        }
      })

      # Return the checkout URL and open it in a new window
      @checkout_url = session.url
      
      respond_to do |format|
        format.html { redirect_to @checkout_url, allow_other_host: true }
        format.turbo_stream { render 'create_checkout_session' }
      end
    rescue Stripe::StripeError => e
      redirect_to settings_subscription_path, alert: "Error al crear la sesión de pago: #{e.message}"
    end
  end

  # Success callback after successful payment
  def success
    @user = Current.user
    plan_id = params[:plan_id]

    # Verify the plan exists
    @plan = SubscriptionPlan.find_by(id: plan_id)
    if @plan.nil?
      redirect_to settings_subscription_path, alert: "El plan seleccionado no existe."
      return
    end

    # Update the subscription status
    subscription = @user.subscription || @user.build_subscription
    subscription.subscription_plan = @plan
    subscription.status = "active"
    subscription.current_period_start = Time.current
    subscription.current_period_end = 1.month.from_now

    if subscription.save
      redirect_to settings_subscription_path, notice: "¡Gracias por tu suscripción al #{@plan.name}!"
    else
      redirect_to settings_subscription_path, alert: "No se pudo procesar tu suscripción. Por favor, contacta a soporte."
    end
  end

  # Cancel callback if payment is cancelled
  def cancel
    redirect_to settings_subscription_path, alert: "Has cancelado el proceso de pago."
  end

  # Webhook endpoint for Stripe events
  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError
      render json: { error: "Invalid payload" }, status: 400
      return
    rescue Stripe::SignatureVerificationError
      render json: { error: "Invalid signature" }, status: 400
      return
    end

    # Handle the event
    case event.type
    when "checkout.session.completed"
      handle_checkout_session_completed(event.data.object)
    when "invoice.paid"
      handle_invoice_paid(event.data.object)
    when "invoice.payment_failed"
      handle_invoice_payment_failed(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "customer.subscription.updated"
      handle_subscription_updated(event.data.object)
    end

    render json: { received: true }
  end

  private

  def handle_checkout_session_completed(session)
    # Get user and plan from metadata
    user_id = session.metadata.user_id
    plan_id = session.metadata.plan_id

    user = User.find_by(id: user_id)
    plan = SubscriptionPlan.find_by(id: plan_id)

    return unless user && plan

    # Create or update subscription
    subscription = user.subscription || user.build_subscription
    subscription.subscription_plan = plan
    subscription.stripe_customer_id = session.customer

    # We'll update more details when we get the invoice.paid event
    subscription.status = "active"
    subscription.save
  end

  def handle_invoice_paid(invoice)
    # Find the subscription
    stripe_subscription_id = invoice.subscription
    return unless stripe_subscription_id

    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription_id)
    return unless subscription

    # Update subscription details
    stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)

    subscription.update(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    # Create payment history if the model exists
    if defined?(PaymentHistory) && subscription.user
      subscription.user.payment_histories.create!(
        amount: invoice.amount_paid,
        status: "completed",
        payment_method: "tarjeta",
        description: "Pago de suscripción #{subscription.subscription_plan&.name || 'Plan'}"
      )
    end
  end

  def handle_invoice_payment_failed(invoice)
    # Find the subscription
    stripe_subscription_id = invoice.subscription
    return unless stripe_subscription_id

    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription_id)
    return unless subscription

    # Update subscription status
    subscription.update(status: "past_due")

    # Notify the user (you could send an email here)
  end

  def handle_subscription_deleted(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    # Update subscription status
    subscription.update(status: "canceled")
  end

  def handle_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    # Update subscription details
    subscription.update(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at: stripe_subscription.cancel_at ? Time.at(stripe_subscription.cancel_at) : nil
    )
  end
end
