# Configuración para la autenticación de usuarios
Rails.application.config.to_prepare do
  ApplicationController.class_eval do
    before_action :set_current_user
    
    private
    
    def set_current_user
      if session_token = cookies.signed[:session_token]
        if session = Session.find_by(id: session_token)
          Current.session = session
        end
      end
    end
  end
end
