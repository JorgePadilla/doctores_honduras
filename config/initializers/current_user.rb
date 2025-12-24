# Configuración para establecer Current.user en cada solicitud
Rails.application.config.to_prepare do
  ApplicationController.class_eval do
    before_action :set_current_attributes
    
    private
    
    def set_current_attributes
      Current.session = nil
      
      if session_token = cookies.signed[:session_token]
        Current.session = Session.find_by(id: session_token)
      end
    end
  end
end
