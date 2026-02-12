class Service < ApplicationRecord
  belongs_to :specialty, optional: true

  has_many :establishment_services, dependent: :destroy
  has_many :establishments, through: :establishment_services
  has_many :doctor_services, dependent: :destroy
  has_many :doctor_profiles, through: :doctor_services

  validates :name, presence: true, uniqueness: true

  scope :for_specialty, ->(specialty_id) { where(specialty_id: [specialty_id, nil]) }
  scope :general, -> { where(specialty_id: nil) }
end
