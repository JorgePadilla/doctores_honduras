class SettingsController < ApplicationController
  before_action :require_authentication
  
  def index
    @user = Current.user
    @subscription = @user.subscription
  end
  
  def account
    @user = Current.user
  end
  
  def subscription
    @user = Current.user
    @subscription = @user.subscription
    @plans = SubscriptionPlan.all
  end
  
  def notifications
    @user = Current.user
    @notification_preferences = @user.notification_preference || @user.build_notification_preference
  end
  
  def security
    @user = Current.user
    @active_sessions = @user.sessions.order(created_at: :desc)
  end
  
  def language
    @user = Current.user
  end
  
  def update_language
    @user = Current.user
    if @user.update(language_params)
      # Actualizar el idioma en la sesión actual
      session[:locale] = @user.language.to_sym
      # Establecer el idioma para la solicitud actual
      I18n.locale = @user.language.to_sym
      
      # Mostrar el mensaje de éxito en el idioma seleccionado
      success_message = @user.language == 'es' ? "Idioma actualizado correctamente." : "Language updated successfully."
      
      redirect_to settings_language_path, notice: success_message
    else
      render :language, status: :unprocessable_entity
    end
  end
  
  def update_notifications
    @user = Current.user
    @notification_preferences = @user.notification_preference || @user.build_notification_preference
    
    if @notification_preferences.update(notification_params)
      redirect_to settings_notifications_path, notice: "Preferencias de notificaciones actualizadas correctamente."
    else
      render :notifications, status: :unprocessable_entity
    end
  end
  
  def subscribe
    @user = Current.user
    plan_id = params[:plan_id]
    
    # Verificar que el plan existe
    @plan = SubscriptionPlan.find_by(id: plan_id)
    if @plan.nil?
      redirect_to settings_subscription_path, alert: "El plan seleccionado no existe."
      return
    end
    
    # Para simplificar, activamos directamente cualquier plan sin proceso de pago
    # En un entorno de producción, aquí se integraría con un sistema de pagos real
    activate_subscription(@plan)
  end
  
  def process_payment
    @user = Current.user
    plan_id = params[:plan_id]
    
    # Verificar que el plan existe
    @plan = SubscriptionPlan.find_by(id: plan_id)
    if @plan.nil?
      redirect_to settings_subscription_path, alert: "El plan seleccionado no existe."
      return
    end
    
    # Aquí iría la integración real con un procesador de pagos como Stripe
    # Por ahora, simulamos un pago exitoso
    
    # Validar la información de la tarjeta (simulado)
    unless params[:card_number].present? && params[:expiry].present? && params[:cvv].present? && params[:terms] == "1"
      flash.now[:alert] = "Por favor completa todos los campos requeridos y acepta los términos y condiciones."
      render :payment
      return
    end
    
    # Activar la suscripción
    activate_subscription(@plan, "tarjeta")
  end
  
  def activate_subscription(plan, payment_method = "gratuito")
    subscription = @user.subscription || @user.build_subscription
    subscription.subscription_plan_id = plan.id
    subscription.status = "active"
    subscription.current_period_start = Time.current
    subscription.current_period_end = 1.month.from_now
    
    if subscription.save
      begin
        # Registrar el pago en el historial si la tabla existe y el plan no es gratuito
        if ActiveRecord::Base.connection.table_exists?('payment_histories') && plan.price > 0
          @user.payment_histories.create!(
            amount: plan.price,
            status: "completed",
            payment_method: payment_method,
            description: "Suscripción a #{plan.name}"
          )
        end
      rescue => e
        # Capturar cualquier error pero permitir que la suscripción continúe
        Rails.logger.error("Error al crear historial de pago: #{e.message}")
      end
      
      redirect_to settings_subscription_path, notice: "Te has suscrito exitosamente al #{plan.name}."
    else
      redirect_to settings_subscription_path, alert: "No se pudo procesar tu suscripción. Por favor, intenta de nuevo."
    end
  end
  
  def cancel_subscription
    @user = Current.user
    subscription = @user.subscription
    
    if subscription.nil?
      redirect_to settings_subscription_path, alert: "No tienes una suscripción activa."
      return
    end
    
    # En un sistema real, aquí se comunicaría con el proveedor de pagos
    # para cancelar la suscripción en su sistema
    
    # Marcamos la suscripción como cancelada pero mantenemos el acceso hasta el final del período
    subscription.status = "canceled"
    
    if subscription.save
      redirect_to settings_subscription_path, notice: "Tu suscripción ha sido cancelada. Tendrás acceso a las características premium hasta el #{subscription.current_period_end.strftime('%d/%m/%Y')}."
    else
      redirect_to settings_subscription_path, alert: "No se pudo cancelar tu suscripción. Por favor, intenta de nuevo."
    end
  end
  
  private
  
  def language_params
    params.require(:user).permit(:language)
  end
  
  def notification_params
    params.require(:notification_preference).permit(:email_notifications, :marketing_emails, :new_features_notifications, :security_alerts)
  end
end
