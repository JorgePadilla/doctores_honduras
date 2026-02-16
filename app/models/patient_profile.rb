class PatientProfile < ApplicationRecord
  belongs_to :user
  belongs_to :department, optional: true
  belongs_to :city, optional: true

  validates :name, presence: true
end
