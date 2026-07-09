class ReportMailer < ApplicationMailer
  # Weekly visit-stats email for paid doctors (Profesional/Elite) — reuses
  # DoctorAnalytics (same numbers as /estadisticas).
  def weekly_stats(doctor_profile)
    @doctor = doctor_profile
    @analytics = DoctorAnalytics.new(doctor_profile, range: 7.days.ago..Time.current)
    @tier = doctor_profile.user.subscription&.subscription_plan&.tier || "gratis"
    @views = @analytics.views_this_week
    @trend = @analytics.weekly_trend_pct

    mail(
      to: doctor_profile.user.email,
      subject: "Tu semana en Doctores Honduras: #{@views} #{@views == 1 ? 'visita' : 'visitas'}"
    )
  end
end
