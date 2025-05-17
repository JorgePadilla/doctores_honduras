class Establishment < ApplicationRecord
  has_many :doctor_establishments, dependent: :destroy
  has_many :doctor_profiles, through: :doctor_establishments

  validates :name, presence: true
  validates :est_type, presence: true
  validates :address, presence: true
end
