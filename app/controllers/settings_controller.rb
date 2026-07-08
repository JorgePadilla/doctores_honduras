class SettingsController < ApplicationController
  before_action :require_authentication

  # Resumen del hub "Mi cuenta" — absorbe el antiguo Panel de Control.
  def index
    @user = Current.user
    @profile_type = @user.profile_type
    @subscription = @user.subscription
    @plan = @subscription&.subscription_plan

    case @profile_type
    when "doctor"
      @doctor_profile = @user.doctor_profile
      @completeness = compute_doctor_completeness
      if @doctor_profile
        @profile_views_total = @doctor_profile.profile_views.count
        @profile_views_week = @doctor_profile.profile_views.this_week.count
      end
    when "hospital", "clinic"
      @establishment = @user.establishments.first
      @completeness = compute_establishment_completeness
      if @establishment
        @profile_views_total = @establishment.profile_views.count
        @profile_views_week = @establishment.profile_views.this_week.count
      end
    when "vendor"
      @supplier = @user.supplier
      @products_count = @supplier&.products&.count || 0
      @leads_count = @supplier&.lead_contacts&.count || 0
      @completeness = compute_vendor_completeness
      if @supplier
        @profile_views_total = @supplier.profile_views.count
        @profile_views_week = @supplier.profile_views.this_week.count
      end
    when "paciente"
      @patient_profile = @user.patient_profile
      @upcoming_appointments = @user.patient_appointments.active.upcoming.includes(doctor_profile: :specialty, doctor_branch: []).order(:appointment_date, :start_time).limit(10)
      @past_appointments = @user.patient_appointments.where("appointment_date < ? OR (appointment_date = ? AND end_time < ?)", Date.current, Date.current, Time.current).includes(doctor_profile: :specialty, doctor_branch: []).order(appointment_date: :desc, start_time: :desc).limit(10)
      @completeness = compute_patient_completeness
    else
      @completeness = 0
    end
  end

  def subscription
    @user = Current.user
    @subscription = @user.subscription
    # Show plans relevant to the user's profile type
    plan_profile = @user.profile_type == "clinic" ? "hospital" : @user.profile_type
    if plan_profile.present?
      @plans = SubscriptionPlan.for_profile_type(plan_profile).ordered
    else
      @plans = SubscriptionPlan.where(profile_type: nil).or(SubscriptionPlan.where(profile_type: ""))
    end
  end

  # Preferencias: notificaciones + idioma en una sola pestaña.
  def preferences
    @user = Current.user
    @notification_preferences = @user.notification_preference || @user.build_notification_preference
  end

  def security
    @user = Current.user
    @active_sessions = @user.sessions.order(created_at: :desc)
  end

  # Cambio de contraseña real (has_secure_password). Nunca registramos la
  # contraseña; solo leemos los tres campos necesarios directamente.
  def update_password
    @user = Current.user

    unless @user.authenticate(params[:current_password])
      redirect_to settings_security_path, alert: "La contraseña actual es incorrecta."
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to settings_security_path, notice: "Contraseña actualizada."
    else
      redirect_to settings_security_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  def update_language
    @user = Current.user
    old_language = @user.language

    if @user.update(language_params)
      new_language = @user.language

      # Solo actualizar la sesión y el locale si realmente cambió el idioma
      if old_language != new_language
        # Actualizar el idioma en la sesión actual
        session[:locale] = new_language.to_sym
        # Establecer el idioma para la solicitud actual
        I18n.locale = new_language.to_sym

        Rails.logger.info "Language changed from #{old_language} to #{new_language}"
        Rails.logger.info "Session locale set to: #{session[:locale]}"
        Rails.logger.info "I18n.locale set to: #{I18n.locale}"
      end

      # Mostrar el mensaje de éxito en el idioma seleccionado
      success_message = new_language == "es" ? "Idioma actualizado correctamente." : "Language updated successfully."

      flash[:success] = success_message
      redirect_to settings_preferences_path
    else
      render :preferences, status: :unprocessable_entity
    end
  end

  def update_notifications
    @user = Current.user
    @notification_preferences = @user.notification_preference || @user.build_notification_preference

    if @notification_preferences.update(notification_params)
      flash[:success] = "Preferencias de notificaciones actualizadas correctamente."
      redirect_to settings_preferences_path
    else
      render :preferences, status: :unprocessable_entity
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
        if ActiveRecord::Base.connection.table_exists?("payment_histories") && plan.price > 0
          @user.payment_histories.create!(
            amount: 1,
            status: "completed",
            payment_method: payment_method,
            description: "Suscripción a #{plan.name}"
          )
        end
      rescue => e
        # Capturar cualquier error pero permitir que la suscripción continúe
        Rails.logger.error("Error al crear historial de pago: #{e.message}")
      end

      Notification.notify(user: @user, type: "pago_exitoso", title: "Suscripción activada",
        message: "Te suscribiste al plan #{plan.name}.", url: settings_subscription_path, icon: "credit_card")
      flash[:success] = "Te has suscrito exitosamente al #{plan.name}."
      redirect_to settings_subscription_path
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
      Notification.notify(user: @user, type: "suscripcion_cancelada", title: "Suscripción cancelada",
        message: "Cancelaste tu suscripción; tienes acceso hasta el #{subscription.current_period_end.strftime('%d/%m/%Y')}.", url: settings_subscription_path, icon: "credit_card")
      flash[:success] = "Tu suscripción ha sido cancelada. Tendrás acceso a las características premium hasta el #{subscription.current_period_end.strftime('%d/%m/%Y')}."
      redirect_to settings_subscription_path
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

  # Completitud del perfil para el Resumen (incluye servicios y ubicaciones).
  def compute_doctor_completeness
    @doctor_profile ? @doctor_profile.completeness_pct : 0
  end

  def compute_establishment_completeness
    return 0 unless @establishment
    fields = [ @establishment.name, @establishment.address, @establishment.phone,
               @establishment.department_id, @establishment.city_id, @establishment.description,
               @establishment.logo_url ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end

  def compute_vendor_completeness
    return 0 unless @supplier
    fields = [ @supplier.name, @supplier.phone, @supplier.category,
               @supplier.description, @supplier.email, @supplier.website,
               @supplier.department_id ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end

  def compute_patient_completeness
    return 0 unless @patient_profile
    fields = [ @patient_profile.name, @patient_profile.phone,
               @patient_profile.date_of_birth, @patient_profile.department_id,
               @patient_profile.city_id ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end
end
