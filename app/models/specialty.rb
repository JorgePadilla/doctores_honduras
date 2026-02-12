class Specialty < ApplicationRecord
  has_many :establishment_specialties, dependent: :destroy
  has_many :establishments, through: :establishment_specialties
  has_many :subspecialties, dependent: :destroy
  has_many :doctor_profiles
  has_many :services

  validates :name, presence: true, uniqueness: true
end
