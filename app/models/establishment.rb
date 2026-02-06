class Establishment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department, optional: true
  belongs_to :city, optional: true

  # Doctor relationships
  has_many :doctor_establishments, dependent: :destroy
  has_many :doctor_profiles, through: :doctor_establishments

  # Specialty relationships
  has_many :establishment_specialties, dependent: :destroy
  has_many :specialties, through: :establishment_specialties

  # Service relationships
  has_many :establishment_services, dependent: :destroy
  has_many :services, through: :establishment_services

  has_many :profile_views, as: :viewable, dependent: :destroy

  validates :name, presence: true
  validates :est_type, presence: true
  validates :address, presence: true
end
