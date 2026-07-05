module ApplicationHelper
  def paid_plan?(plan)
    plan.present? && !plan.free?
  end

  # Percentage change of current vs previous. Returns an Integer (can be negative)
  # or nil when there's no baseline (previous is zero/blank).
  def pct_delta(current, previous)
    return nil if previous.nil? || previous.zero?
    (((current - previous) / previous.to_f) * 100).round
  end

  # Returns a Google Maps URL for a location. Uses the explicit map_link when
  # present; otherwise builds a Maps "search" URL from the given address parts
  # (blank parts are ignored). Returns nil when there's nothing to link to.
  def google_maps_url(map_link: nil, address_parts: [])
    return map_link if map_link.present?

    query = Array(address_parts).map { |p| p.to_s.strip.presence }.compact.join(", ")
    return nil if query.blank?

    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(query)}"
  end

  # Renders a small ▲/▼ delta badge (green up, red down). Returns "" when no baseline.
  def delta_badge(current, previous)
    d = pct_delta(current, previous)
    return "".html_safe if d.nil?
    up = d >= 0
    color = up ? "text-green-600 dark:text-green-400" : "text-red-600 dark:text-red-400"
    content_tag(:span, "#{up ? '▲' : '▼'} #{d.abs}%", class: "inline-flex items-center text-xs font-medium #{color}")
  end
end
