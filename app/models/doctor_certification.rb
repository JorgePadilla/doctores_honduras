class DoctorCertification < ApplicationRecord
  belongs_to :doctor_profile

  validates :name, presence: true

  scope :ordered, -> { order(:position) }
end
