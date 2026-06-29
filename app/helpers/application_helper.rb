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

  # Renders a small ▲/▼ delta badge (green up, red down). Returns "" when no baseline.
  def delta_badge(current, previous)
    d = pct_delta(current, previous)
    return "".html_safe if d.nil?
    up = d >= 0
    color = up ? "text-green-600 dark:text-green-400" : "text-red-600 dark:text-red-400"
    content_tag(:span, "#{up ? '▲' : '▼'} #{d.abs}%", class: "inline-flex items-center text-xs font-medium #{color}")
  end
end
