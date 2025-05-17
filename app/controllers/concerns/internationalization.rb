module Internationalization
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    # Try to get locale from user preferences if logged in
    if Current.user && Current.user.language.present?
      Current.user.language.to_sym if I18n.available_locales.include?(Current.user.language.to_sym)
    # Try to get locale from params
    elsif params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      session[:locale] = params[:locale].to_sym
    # Try to get locale from session
    elsif session[:locale] && I18n.available_locales.include?(session[:locale].to_sym)
      session[:locale]
    # Try to get locale from HTTP Accept-Language header
    elsif request.env['HTTP_ACCEPT_LANGUAGE']
      locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      locale.to_sym if I18n.available_locales.include?(locale.to_sym)
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
