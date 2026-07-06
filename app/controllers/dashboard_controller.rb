class DashboardController < ApplicationController
  # El antiguo "Panel de Control" se fusionó con Configuración en el hub
  # "Mi cuenta" (Fase 2). Se conserva la ruta como redirect para no romper los
  # múltiples enlaces existentes a dashboard_path (onboarding, perfiles, etc.).
  def index
    redirect_to settings_path
  end
end
