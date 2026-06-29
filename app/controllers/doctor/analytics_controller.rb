class Doctor::AnalyticsController < ApplicationController
  before_action :require_analytics_access

  ALLOWED_DAYS = [ 7, 30, 90, 365 ].freeze

  def index
    @days = params[:days].to_i
    @days = 30 unless ALLOWED_DAYS.include?(@days)
    @analytics = DoctorAnalytics.new(@doctor_profile, range: @days.days.ago..Time.current)
    @previous = DoctorAnalytics.new(@doctor_profile, range: (@days * 2).days.ago..@days.days.ago)

    respond_to do |format|
      format.html
      format.csv { send_data @analytics.to_csv, filename: "estadisticas-#{Date.current}.csv" }
    end
  end

  private

  # Gated to paid doctor tiers (matches the "Estadísticas" / "Estadísticas avanzadas"
  # features of the Profesional / Elite plans).
  def require_analytics_access
    @doctor_profile = Current.user&.doctor_profile
    @tier = Current.user&.subscription&.subscription_plan&.tier || "gratis"

    unless @doctor_profile && %w[profesional elite].include?(@tier)
      redirect_to dashboard_path, alert: "Las estadísticas están disponibles en los planes Profesional y Elite."
    end
  end
end
