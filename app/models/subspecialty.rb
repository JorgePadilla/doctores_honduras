class Subspecialty < ApplicationRecord
  belongs_to :specialty
  has_many :doctor_profiles

  validates :name, presence: true
  validates :specialty_id, presence: true
end