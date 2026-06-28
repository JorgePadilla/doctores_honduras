class Ahoy::Store < Ahoy::DatabaseStore
  # Enrich each visit with geolocation from the local MaxMind GeoLite2 DB, inline
  # (no background worker needed). Falls back gracefully when the DB file is absent.
  def track_visit(data)
    ip = ahoy.request&.remote_ip
    super(data.merge(IpGeolocator.lookup(ip)))
  end
end

# Enable ahoy.js so we can track client-side events (clicks) in addition to visits.
Ahoy.api = true

# We geocode inline via IpGeolocator (above) using a local MaxMind DB, so Ahoy's
# own (async, Geocoder-based) geocoding stays off.
Ahoy.geocode = false

# Privacy: store masked IPs (last octet / network suffix zeroed). City-level geo
# still works because we geocode from the real IP before masking. The data we sell
# to doctors is aggregate only — never per-visitor PII.
Ahoy.mask_ips = true
