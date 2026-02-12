class DoctorEducation < ApplicationRecord
  belongs_to :doctor_profile

  validates :institution, presence: true

  scope :ordered, -> { order(:position) }
end
