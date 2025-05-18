# Set default locale to Spanish
I18n.default_locale = :es

# Load all locales from config/locales/*.yml
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]

# Whitelist available locales
I18n.available_locales = [:es, :en]

# Set locale from session or default
Rails.application.config.middleware.use ActionDispatch::Session::CookieStore

module SetLocale
  def self.before(controller)
    # Try to get locale from session
    locale = controller.session[:locale]
    
    # If user is logged in, use their preference
    if defined?(Current) && Current.user && Current.user.language.present?
      locale = Current.user.language
    end
    
    # Fall back to default locale if none set
    locale = I18n.default_locale unless locale && I18n.available_locales.include?(locale.to_sym)
    
    # Set the locale for this request
    I18n.locale = locale
  end
end

# Ensure locale is set before each request
Rails.application.config.to_prepare do
  ApplicationController.before_action do
    SetLocale.before(self)
  end
end
