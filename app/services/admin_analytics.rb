# Site-wide analytics aggregations over Ahoy visits + events, for the admin panel.
# All queries are scoped to a time range (default last 30 days).
class AdminAnalytics
  EVENT_NAMES = {
    profile_views: "Profile View",
    contact_clicks: "Contact Click",
    bookings_started: "Booking Started",
    bookings_completed: "Booking Completed",
    searches: "Search"
  }.freeze

  def initialize(range: 30.days.ago..Time.current)
    @range = range
  end

  def visits
    @visits ||= Ahoy::Visit.where(started_at: @range)
  end

  def events
    @events ||= Ahoy::Event.where(time: @range)
  end

  # --- KPIs ---
  def total_visits = visits.count
  def unique_visitors = visits.distinct.count(:visitor_token)
  def logged_in_visits = visits.where.not(user_id: nil).count

  def visits_by_day
    visits.group(Arel.sql("DATE(started_at)")).count.sort.to_h
  end

  # --- Acquisition ---
  def top_referring_domains(limit = 10) = top(:referring_domain, limit)
  def top_landing_pages(limit = 10) = top(:landing_page, limit)
  def top_utm_sources(limit = 10) = top(:utm_source, limit)
  def top_utm_campaigns(limit = 10) = top(:utm_campaign, limit)

  # --- Geo ---
  def by_country(limit = 10) = top(:country, limit)
  def by_region(limit = 15) = top(:region, limit)
  def by_city(limit = 15) = top(:city, limit)

  # --- Technology ---
  def by_device = top(:device_type, 10)
  def by_browser(limit = 8) = top(:browser, limit)
  def by_os(limit = 8) = top(:os, limit)

  # --- Conversion funnel ---
  def funnel
    EVENT_NAMES.transform_values { |name| events.where(name: name).count }
  end

  # --- Top entities by profile views ---
  def top_doctors(limit = 10) = top_profiles("DoctorProfile", DoctorProfile, limit)
  def top_establishments(limit = 10) = top_profiles("Establishment", Establishment, limit)
  def top_suppliers(limit = 10) = top_profiles("Supplier", Supplier, limit)

  def recent_visits(limit = 20)
    visits.order(started_at: :desc).limit(limit)
  end

  private

  # Returns a {value => count} hash, top `limit`, sorted desc, ignoring blanks.
  def top(column, limit, scope: visits)
    scope.where.not(column => [ nil, "" ])
         .group(column).count
         .sort_by { |_k, v| -v }.first(limit).to_h
  end

  def top_profiles(viewable_type, model, limit)
    counts = events.where(name: EVENT_NAMES[:profile_views])
                   .where("properties ->> 'viewable_type' = ?", viewable_type)
                   .group(Arel.sql("properties ->> 'viewable_id'")).count
                   .sort_by { |_k, v| -v }.first(limit)
    ids = counts.map { |id, _| id.to_i }
    records = model.where(id: ids).index_by(&:id)
    counts.map do |id, count|
      rec = records[id.to_i]
      label = rec&.try(:display_name) || rec&.try(:name) || "##{id}"
      [ label, count ]
    end
  end
end
