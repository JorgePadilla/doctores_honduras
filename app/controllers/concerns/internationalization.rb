module Internationalization
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    locale = extract_locale || I18n.default_locale
    I18n.locale = locale.to_sym
    Rails.logger.debug "Setting locale to: #{I18n.locale}"
  end

  def extract_locale
    locale = nil

    # Try to get locale from session first (highest priority)
    if session[:locale].present? && I18n.available_locales.include?(session[:locale].to_sym)
      locale = session[:locale]
      Rails.logger.debug "Using locale from session: #{locale}"
    # Try to get locale from user preferences if logged in
    elsif Current.user && Current.user.language.present? && I18n.available_locales.include?(Current.user.language.to_sym)
      locale = Current.user.language
      # Update session to match user preference
      session[:locale] = locale
      Rails.logger.debug "Using locale from user preferences: #{locale}"
    # Try to get locale from params
    elsif params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      locale = params[:locale]
      session[:locale] = locale
      Rails.logger.debug "Using locale from params: #{locale}"
    # Try to get locale from HTTP Accept-Language header
    elsif request.env["HTTP_ACCEPT_LANGUAGE"].present?
      browser_locale = request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
      if browser_locale.present? && I18n.available_locales.include?(browser_locale.to_sym)
        locale = browser_locale
        session[:locale] = locale
        Rails.logger.debug "Using locale from browser: #{locale}"
      end
    end

    locale || I18n.default_locale
  end

  # No incluimos el locale en las URLs para mantenerlas limpias
  # El idioma se maneja a través de la sesión
  def default_url_options
    {}
  end
end
