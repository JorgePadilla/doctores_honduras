class ProfileViewTracker
  def self.track(viewable:, viewer: nil, ip_address: nil, user_agent: nil)
    return if should_skip?(viewable, viewer)
    return if recently_viewed?(viewable, viewer, ip_address)

    ProfileView.create!(
      viewable: viewable,
      viewer: viewer,
      ip_address: ip_address,
      user_agent: user_agent&.truncate(255)
    )
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
