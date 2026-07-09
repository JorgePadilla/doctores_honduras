# Sends the weekly stats email to every paid doctor (Profesional/Elite) who has
# visits this week and hasn't opted out of email notifications.
# Scheduled Mondays 7am America/Tegucigalpa via config/recurring.yml.
class WeeklyDoctorReportsJob < ApplicationJob
  queue_as :default

  PAID_TIERS = %w[profesional elite].freeze

  def perform
    sent = 0
    DoctorProfile.includes(user: { subscription: :subscription_plan }).find_each do |doctor|
      user = doctor.user
      next unless user&.email.present?
      next unless PAID_TIERS.include?(user.subscription&.subscription_plan&.tier)
      next unless user.wants_email?
      next if DoctorAnalytics.new(doctor).views_this_week.zero? # skip empty reports

      ReportMailer.weekly_stats(doctor).deliver_later
      sent += 1
    end
    Rails.logger.info "WeeklyDoctorReportsJob: queued #{sent} report(s)."
  end
end
