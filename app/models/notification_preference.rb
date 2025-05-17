class NotificationPreference < ApplicationRecord
  belongs_to :user
  
  # Campos sugeridos:
  # - email_notifications (boolean)
  # - marketing_emails (boolean)
  # - new_features_notifications (boolean)
  # - security_alerts (boolean)
  
  validates :user_id, presence: true, uniqueness: true
end
