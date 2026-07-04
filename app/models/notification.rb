class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :notification_type, presence: true
  validates :message, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  def unread?
    !read?
  end

  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end

  # Single creation entry point used by every notifier. No-op when user is nil
  # (e.g. a supplier with no owner, or an appointment with no linked patient).
  def self.notify(user:, type:, message:, title: nil, url: nil, icon: nil, notifiable: nil)
    return if user.nil?

    create!(
      user: user,
      notification_type: type,
      title: title,
      message: message,
      url: url,
      icon: icon,
      notifiable: notifiable
    )
  end
end
