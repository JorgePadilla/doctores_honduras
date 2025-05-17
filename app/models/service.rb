class Service < ApplicationRecord
  has_many :establishment_services, dependent: :destroy
  has_many :establishments, through: :establishment_services
  
  validates :name, presence: true, uniqueness: true
end
