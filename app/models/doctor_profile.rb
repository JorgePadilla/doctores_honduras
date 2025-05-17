class DoctorProfile < ApplicationRecord
  belongs_to :user
  has_many :doctor_establishments, dependent: :destroy
  has_many :establishments, through: :doctor_establishments

  validates :name, presence: true
  validates :specialization, presence: true
end
