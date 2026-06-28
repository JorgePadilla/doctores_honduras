class Ahoy::Store < Ahoy::DatabaseStore
  # Enrich each visit with geolocation from the local MaxMind GeoLite2 DB, inline
  # (no background worker needed). Uses the real client IP from X-Forwarded-For
  # (Railway's proxy makes remote_ip private). Falls back gracefully if no DB / no geo.
  def track_visit(data)
    super(data.merge(IpGeolocator.from_request(ahoy.request)))
  end
end

# Associate visits/events with the logged-in user (the app uses Current.user, not a
# `current_user` controller method, so Ahoy's default lookup wouldn't find it).
Ahoy.user_method = ->(_controller) { Current.user }

# Enable ahoy.js so we can track client-side events (clicks) in addition to visits.
Ahoy.api = true

# We geocode inline via IpGeolocator (above) using a local MaxMind DB, so Ahoy's
# own (async, Geocoder-based) geocoding stays off.
Ahoy.geocode = false

# Privacy: store masked IPs (last octet / network suffix zeroed). City-level geo
# still works because we geocode from the real IP before masking. The data we sell
# to doctors is aggregate only — never per-visitor PII.
Ahoy.mask_ips = true
