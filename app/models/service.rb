class Service < ApplicationRecord
  has_many :establishment_services, dependent: :destroy
  has_many :establishments, through: :establishment_services
  has_many :doctor_services, dependent: :destroy
  has_many :doctor_profiles, through: :doctor_services
  
  validates :name, presence: true, uniqueness: true
end
