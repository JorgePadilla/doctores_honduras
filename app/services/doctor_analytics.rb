# Per-doctor visit analytics for the in-app report (and, later, the weekly email).
#
# Headline counts come from ProfileView (history-inclusive, deduped — matches the
# dashboard). Rich dimensions (geo, referrers, device, contact-click funnel) come
# from Ahoy and only reflect data since analytics was enabled.
#
# All doctor-facing data is AGGREGATE — never per-visitor PII.
class DoctorAnalytics
  SEARCH_DOMAINS = %w[%google% %bing% %yahoo% %duckduckgo% %ecosia%].freeze

  def initialize(doctor_profile, range: 30.days.ago..Time.current)
    @doctor = doctor_profile
    @range = range
  end

  # --- Headline counts (ProfileView, history-inclusive) ---
  def total_views = @doctor.profile_views.count
  def views_this_week = @doctor.profile_views.where(created_at: 1.week.ago..Time.current).count
  def views_last_week = @doctor.profile_views.where(created_at: 2.weeks.ago..1.week.ago).count
  def views_in_range = @doctor.profile_views.where(created_at: @range).count

  def weekly_trend_pct
    prev = views_last_week
    return nil if prev.zero?
    (((views_this_week - prev) / prev.to_f) * 100).round
  end

  # --- Rich dimensions (Ahoy, range-scoped) ---
  def visits
    @visits ||= Ahoy::Visit.where(id: view_events.distinct.pluck(:visit_id).compact)
  end

  def by_region(limit = 8) = top(visits, :region, limit)
  def by_city(limit = 8) = top(visits, :city, limit)
  def by_device = top(visits, :device_type, 5)
  def top_referrers(limit = 8) = top(visits, :referring_domain, limit)

  def sources_breakdown
    total = visits.count
    return {} if total.zero?
    search = visits.where(SEARCH_DOMAINS.map { "referring_domain ILIKE ?" }.join(" OR "), *SEARCH_DOMAINS).count
    referral = visits.where.not(referring_domain: [ nil, "" ]).count - search
    direct = total - search - referral
    { "Directo" => [ direct, 0 ].max, "Búsqueda" => search, "Referido" => [ referral, 0 ].max }
  end

  def contact_clicks
    events_named("Contact Click").group(Arel.sql("properties ->> 'kind'")).count.sort_by { |_k, v| -v }.to_h
  end

  def bookings_started = events_named("Booking Started").count
  def bookings_completed = events_named("Booking Completed").count

  private

  def view_events = events_named("Profile View")

  def events_named(name)
    Ahoy::Event.where(name: name, time: @range)
               .where("properties ->> 'viewable_type' = ? AND properties ->> 'viewable_id' = ?",
                      "DoctorProfile", @doctor.id.to_s)
  end

  def top(scope, col, limit)
    scope.where.not(col => [ nil, "" ]).group(col).count.sort_by { |_k, v| -v }.first(limit).to_h
  end
end
