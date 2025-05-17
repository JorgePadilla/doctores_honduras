class Specialty < ApplicationRecord
  has_many :establishment_specialties, dependent: :destroy
  has_many :establishments, through: :establishment_specialties
  
  validates :name, presence: true, uniqueness: true
end
