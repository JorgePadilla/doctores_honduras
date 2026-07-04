class SiteSetting < ApplicationRecord
  # Public sections that can be shown/hidden from the admin panel.
  # key => human label (shown in the admin form and used for gating views/routes).
  SECTIONS = {
    "establishments" => "Hospitales y Clínicas",
    "suppliers"      => "Proveedores"
  }.freeze

  validates :key, presence: true, uniqueness: true

  # { "suppliers" => true, "establishments" => false }. Cheap (tiny indexed
  # table); callers memoize per-request rather than across requests so a toggle
  # from the admin panel takes effect immediately across all server processes.
  def self.enabled_map
    pluck(:key, :enabled).to_h
  end

  # Defaults to true when the row is missing, so sections stay visible unless
  # explicitly turned off from the admin panel.
  def self.section_enabled?(key)
    enabled_map.fetch(key.to_s, true)
  end
end
