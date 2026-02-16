class DoctorAgendaSetting < ApplicationRecord
  belongs_to :doctor_profile

  DURATION_OPTIONS = [15, 20, 30, 45, 60].freeze

  validates :appointment_duration, inclusion: { in: DURATION_OPTIONS }
  validates :buffer_minutes, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 30 }
end
