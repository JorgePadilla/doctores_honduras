class EstablishmentService < ApplicationRecord
  belongs_to :establishment
  belongs_to :service
  
  validates :establishment_id, uniqueness: { scope: :service_id }
end
