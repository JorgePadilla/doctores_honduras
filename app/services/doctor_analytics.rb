# Per-doctor visit analytics for the in-app report (and, later, the weekly email).
#
# Headline counts come from ProfileView (history-inclusive, deduped — matches the
# dashboard). Rich dimensions (geo, referrers, device, contact-click funnel) come
# from Ahoy and only reflect data since analytics was enabled.
#
# All doctor-facing data is AGGREGATE — never per-visitor PII.
require "csv"

class DoctorAnalytics
  SEARCH_DOMAINS = %w[%google% %bing% %yahoo% %duckduckgo% %ecosia%].freeze
  DAY_NAMES_ES = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado].freeze

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

  # --- New: unique visitors, conversion, peaks, time series, CSV ---
  def unique_visitors = visits.distinct.count(:visitor_token)
  def ahoy_profile_views = view_events.count
  def contact_click_total = contact_clicks.values.sum

  def conversion_rate
    v = ahoy_profile_views
    v.zero? ? 0 : (contact_click_total * 100.0 / v).round
  end

  def booking_rate
    v = ahoy_profile_views
    v.zero? ? 0 : (bookings_completed * 100.0 / v).round
  end

  def busiest_weekday
    counts = range_view_times.group_by(&:wday).transform_values(&:size)
    return nil if counts.empty?
    DAY_NAMES_ES[counts.max_by { |_k, v| v }.first]
  end

  def busiest_hour
    counts = range_view_times.group_by(&:hour).transform_values(&:size)
    return nil if counts.empty?
    format("%02d:00", counts.max_by { |_k, v| v }.first)
  end

  # Time series for the trend chart: [[label, count], ...]. Day buckets for ranges
  # <= 92 days, weekly buckets for longer ranges; gaps filled with 0.
  def views_by_period
    start_date = @range.begin.to_date
    end_date = @range.end.to_date
    by_week = (end_date - start_date) > 92
    counts = Hash.new(0)
    range_view_times.each do |t|
      d = t.to_date
      counts[by_week ? d.beginning_of_week : d] += 1
    end
    series = []
    cur = by_week ? start_date.beginning_of_week : start_date
    step = by_week ? 7 : 1
    while cur <= end_date
      series << [ cur.strftime("%d/%m"), counts[cur] ]
      cur += step
    end
    series
  end

  def to_csv
    CSV.generate do |csv|
      csv << [ "Estadísticas de visitas", @doctor.display_name ]
      csv << [ "Período", "#{@range.begin.to_date} a #{@range.end.to_date}" ]
      csv << []
      csv << [ "Métrica", "Valor" ]
      csv << [ "Visitas en el período", views_in_range ]
      csv << [ "Visitantes únicos", unique_visitors ]
      csv << [ "Visitas totales (histórico)", total_views ]
      csv << [ "Tasa de conversión (vistas→contacto) %", conversion_rate ]
      csv << [ "Tasa de reserva %", booking_rate ]
      csv << [ "Reservas iniciadas", bookings_started ]
      csv << [ "Reservas completadas", bookings_completed ]
      csv << [ "Día más activo", busiest_weekday ]
      csv << [ "Hora pico", busiest_hour ]
      csv << []
      csv << [ "Visitas por período" ]
      csv << [ "Fecha", "Visitas" ]
      views_by_period.each { |label, c| csv << [ label, c ] }
      [ [ "Cómo te encuentran", sources_breakdown ], [ "Dispositivos", by_device ],
        [ "Departamentos", by_region ], [ "Ciudades", by_city ],
        [ "Sitios que refieren", top_referrers ], [ "Clicks de contacto", contact_clicks ] ].each do |title, data|
        csv << []
        csv << [ title ]
        data.each { |k, v| csv << [ k, v ] }
      end
    end
  end

  private

  def range_view_times
    @range_view_times ||= @doctor.profile_views.where(created_at: @range).pluck(:created_at).map(&:in_time_zone)
  end

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
