class DoctorAgendaSetting < ApplicationRecord
  belongs_to :doctor_profile

  DURATION_OPTIONS = [ 15, 20, 30, 45, 60 ].freeze
  MAX_CONCURRENT_LIMIT = 10

  validates :appointment_duration, inclusion: { in: DURATION_OPTIONS }
  validates :buffer_minutes, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 30 }
  validates :max_concurrent, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_CONCURRENT_LIMIT }
end
