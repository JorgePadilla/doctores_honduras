class AppointmentNotification < ApplicationRecord
  belongs_to :user
  belongs_to :appointment

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
end
