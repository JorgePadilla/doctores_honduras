require "maxmind/db"

# Looks up coarse geolocation for an IP using a local MaxMind GeoLite2-City DB.
#
# Returns a hash with :country, :region, :city, :latitude, :longitude (only the
# keys that resolve). Returns {} when the DB file is missing, the IP is private,
# or anything goes wrong — so analytics ingestion never breaks on geo.
#
# The DB file (db/GeoLite2-City.mmdb) requires a free MaxMind license to download
# and is NOT committed. Until it's present, visits are stored without geo.
class IpGeolocator
  DB_PATH = Rails.root.join("db", "GeoLite2-City.mmdb").freeze

  class << self
    def lookup(ip)
      return {} if ip.blank? || reader.nil?

      record = reader.get(ip)
      return {} unless record

      {
        country: record.dig("country", "names", "en"),
        region: record.dig("subdivisions", 0, "names", "en"),
        city: record.dig("city", "names", "en"),
        latitude: record.dig("location", "latitude"),
        longitude: record.dig("location", "longitude")
      }.compact
    rescue => e
      Rails.logger.debug "IpGeolocator lookup failed for #{ip}: #{e.class} - #{e.message}"
      {}
    end

    def available?
      !reader.nil?
    end

    private

    # Memoized in-memory reader (thread-safe to read concurrently). Nil if no DB file.
    def reader
      return @reader if defined?(@reader)

      @reader =
        if File.exist?(DB_PATH)
          MaxMind::DB.new(DB_PATH.to_s, mode: MaxMind::DB::MODE_MEMORY)
        else
          Rails.logger.info "IpGeolocator: #{DB_PATH} not found — geolocation disabled until present."
          nil
        end
    end
  end
end
