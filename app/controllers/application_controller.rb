class ApplicationController < ActionController::Base
  include Authentication
  include Internationalization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :section_visible?

  # Whether a public section (see SiteSetting::SECTIONS) is currently shown.
  # Memoized per-request so navbar/footer/home checks share a single query.
  def section_visible?(key)
    section_enabled_map.fetch(key.to_s, true)
  end

  # before_action guard: redirect to home when a section is hidden.
  def require_visible_section(key)
    redirect_to root_path unless section_visible?(key)
  end

  private

  def section_enabled_map
    @section_enabled_map ||= SiteSetting.enabled_map
  end
end
