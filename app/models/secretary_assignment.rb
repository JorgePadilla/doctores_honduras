class SecretaryAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :doctor_profile

  validates :user_id, uniqueness: { scope: :doctor_profile_id }
  validates :status, inclusion: { in: %w[active revoked] }

  scope :active, -> { where(status: "active") }
  scope :for_doctor, ->(doctor_profile) { where(doctor_profile: doctor_profile) }
  scope :for_user, ->(user) { where(user: user) }

  before_create :generate_invitation_token, if: -> { invitation_token.blank? }

  def active?
    status == "active"
  end

  def revoke!
    update!(status: "revoked")
  end

  private

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end
end
