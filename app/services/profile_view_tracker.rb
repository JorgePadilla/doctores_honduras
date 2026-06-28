class ProfileViewTracker
  # `ahoy` is the controller's Ahoy tracker. When passed, a rich "Profile View"
  # event is recorded against the current visit (geo/referrer/device/UTM) in
  # addition to the deduped ProfileView row (which remains the history-inclusive
  # visit counter shown on the dashboard).
  def self.track(viewable:, viewer: nil, ahoy: nil, ip_address: nil, user_agent: nil)
    return if should_skip?(viewable, viewer)
    return if recently_viewed?(viewable, viewer, ip_address)

    ProfileView.create!(
      viewable: viewable,
      viewer: viewer,
      ip_address: ip_address,
      user_agent: user_agent&.truncate(255)
    )

    ahoy&.track("Profile View", viewable_type: viewable.class.name, viewable_id: viewable.id)
  rescue => e
    Rails.logger.error "ProfileViewTracker error: #{e.class} - #{e.message}"
  end

  private

  def self.should_skip?(viewable, viewer)
    return false unless viewer

    case viewable
    when DoctorProfile
      viewable.user_id == viewer.id
    when Establishment
      viewable.user_id == viewer.id
    when Supplier
      viewable.user_id == viewer.id
    else
      false
    end
  end

  def self.recently_viewed?(viewable, viewer, ip_address)
    scope = ProfileView.where(viewable: viewable)
                       .where("created_at > ?", 1.hour.ago)

    if viewer
      scope.where(viewer: viewer).exists?
    elsif ip_address
      scope.where(ip_address: ip_address).exists?
    else
      false
    end
  end
end
