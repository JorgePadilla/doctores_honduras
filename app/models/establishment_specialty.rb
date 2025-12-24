class EstablishmentSpecialty < ApplicationRecord
  belongs_to :establishment
  belongs_to :specialty
  
  validates :establishment_id, uniqueness: { scope: :specialty_id }
end
