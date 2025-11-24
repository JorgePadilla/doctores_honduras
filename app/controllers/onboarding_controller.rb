class OnboardingController < ApplicationController
  before_action :require_authentication
  before_action :redirect_if_onboarding_completed
  before_action :set_subscription_plans, only: [:plan_selection, :plan_confirmation]
  before_action :require_plan_selection, only: [:profile_setup, :profile_confirmation]
  
  def plan_selection
    # Display available subscription plans
  end

  def plan_confirmation
    # Handle both POST and GET requests
    if request.post?
      # POST request - process plan selection and create Stripe Setup Intent
      @plan = SubscriptionPlan.find_by(id: params[:plan_id])

      if @plan.nil?
        redirect_to onboarding_plan_selection_path, alert: "Por favor seleccione un plan válido."
        return
      end

      # Determine profile type based on plan name
      profile_type = if @plan.name.downcase.include?('gratuito') || @plan.price == 0
                       'viewer'
                     elsif @plan.name.downcase.include?('hospital')
                       'hospital'
                     elsif @plan.name.downcase.include?('proveedor') || @plan.name.downcase.include?('provider')
                       'provider'
                     else
                       'doctor'
                     end

      # Store the selected plan and profile type in the session
      session[:selected_plan_id] = @plan.id
      session[:profile_type] = profile_type

      # Update user's profile type
      current_user.update(profile_type: profile_type)

      # For free plans, complete onboarding immediately
      if @plan.price == 0
        current_user.update(onboarding_completed: true)
        redirect_to doctors_path
        return
      end

      # For paid plans, create Stripe subscription and show payment form
      begin
        # Update existing subscription or create new one
        subscription = current_user.subscription || current_user.build_subscription
        subscription.subscription_plan = @plan
        subscription.plan_name = @plan.name

        Rails.logger.info("Attempting to save/update subscription for plan: #{@plan.name}, user: #{current_user.id}")

        if subscription.save
          Rails.logger.info("Subscription saved/updated successfully for plan: #{@plan.name}")
        else
          Rails.logger.error("Failed to save/update subscription: #{subscription.errors.full_messages.join(', ')}")
          raise "Failed to save/update subscription: #{subscription.errors.full_messages.join(', ')}"
        end

        Rails.logger.info("Creating Stripe subscription for plan: #{@plan.name}, price: #{@plan.price}")

        # Create Stripe Setup Intent and get client secret
        client_secret = subscription.create_stripe_subscription

        Rails.logger.info("Stripe Setup Intent created, client_secret present: #{client_secret.present?}")

        session[:payment_client_secret] = client_secret if client_secret

        # Show plan confirmation page with embedded Stripe form
        # The view will handle displaying the payment form
        render :plan_confirmation
        return

      rescue => e
        Rails.logger.error("Error creating Stripe subscription: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        redirect_to onboarding_plan_selection_path, alert: "Error al procesar el pago. Por favor intente nuevamente."
        return
      end
    else
      # GET request - show plan confirmation page if valid session exists
      @plan = SubscriptionPlan.find_by(id: session[:selected_plan_id])

      if @plan.nil? || session[:payment_client_secret].blank?
        redirect_to onboarding_plan_selection_path, alert: "Por favor seleccione un plan primero."
        return
      end

      # Show plan confirmation page with existing Stripe data
      render :plan_confirmation
    end
  end

  def payment_success
    # Check if subscription is active (payment was successful via webhook)
    subscription = current_user.subscription

    if subscription&.active?
      # Payment was successful, mark onboarding as completed
      current_user.update(onboarding_completed: true)

      # Clear payment session data
      session.delete(:payment_client_secret)

      flash[:success] = "¡Pago exitoso! Bienvenido a su cuenta."
      redirect_to dashboard_path
    else
      # Payment might still be processing or failed
      # Show a waiting page or redirect to profile setup
      @plan = SubscriptionPlan.find(session[:selected_plan_id])
      render :payment_pending
    end
  end

  def profile_setup
    @plan = SubscriptionPlan.find(session[:selected_plan_id])
    @profile_type = session[:profile_type]
    
    # Redirect to dashboard if user has already completed onboarding
    redirect_if_onboarding_completed
    
    # For viewer profile type (free plan), skip profile setup and go to doctors index
    if @profile_type == 'viewer'
      current_user.update(onboarding_completed: true)
      redirect_to doctors_path
      return
    end
    
    case @profile_type
    when 'doctor'
      @doctor_profile = current_user.doctor_profile || current_user.build_doctor_profile
      @specialties = Specialty.order(:name)
      @subspecialties = []
      @departments = Department.order(:name)
      @cities = City.order(:name)
    when 'hospital', 'provider'
      @establishment = current_user.establishments.build(est_type: @profile_type)
    else
      redirect_to onboarding_plan_selection_path, alert: "Tipo de perfil no válido."
    end
  end

  def profile_confirmation
    @profile_type = session[:profile_type]
    
    case @profile_type
    when 'doctor'
      @doctor_profile = current_user.build_doctor_profile(doctor_profile_params)
      if @doctor_profile.save
        create_subscription
        complete_onboarding
      else
        render :profile_setup
      end
    when 'hospital', 'provider'
      @establishment = current_user.establishments.build(establishment_params)
      if @establishment.save
        create_subscription
        complete_onboarding
      else
        render :profile_setup
      end
    else
      redirect_to onboarding_plan_selection_path, alert: "Tipo de perfil no válido."
    end
  end
  
  private
  
  def set_subscription_plans
    @subscription_plans = SubscriptionPlan.visible
  end
  
  def current_user
    Current.user
  end
  
  def redirect_if_onboarding_completed
    redirect_to dashboard_path if current_user&.onboarding_completed
  end
  
  def require_plan_selection
    unless session[:selected_plan_id].present? && session[:profile_type].present?
      redirect_to onboarding_plan_selection_path, alert: "Por favor seleccione un plan primero."
    end
  end
  
  def create_subscription
    plan = SubscriptionPlan.find(session[:selected_plan_id])
    
    # Create or update subscription
    subscription = current_user.subscription || current_user.build_subscription
    subscription.subscription_plan = plan
    subscription.plan_name = plan.name
    subscription.save
    
    # For paid plans, create Stripe subscription
    if plan.price > 0
      begin
        client_secret = subscription.create_stripe_subscription
        session[:payment_client_secret] = client_secret if client_secret
      rescue => e
        Rails.logger.error("Error creating Stripe subscription: #{e.message}")
      end
    end
  end
  
  def complete_onboarding
    current_user.update(onboarding_completed: true)
    session.delete(:selected_plan_id)
    session.delete(:profile_type)
    
    if session[:payment_client_secret].present?
      redirect_to payment_path, notice: "Por favor complete el pago para activar su suscripción."
    else
      flash[:success] = "¡Configuración completada! Bienvenido a su cuenta."
      redirect_to dashboard_path
    end
  end
  
  def doctor_profile_params
    params.require(:doctor_profile).permit(
      :name, :phone, :bio, :education, :experience, :photo,
      :specialty_id, :subspecialty_id, :department_id, :city_id
    )
  end
  
  def establishment_params
    params.require(:establishment).permit(
      :name, :est_type, :address, :city, :state, 
      :phone, :description, :website, :photo
    )
  end
end
