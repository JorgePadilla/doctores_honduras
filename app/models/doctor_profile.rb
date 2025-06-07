class DoctorProfile < ApplicationRecord
  belongs_to :user
  has_many :doctor_establishments, dependent: :destroy
  has_many :establishments, through: :doctor_establishments
  has_many :doctor_services, dependent: :destroy
  has_many :services, through: :doctor_services

  validates :name, presence: true
  validates :specialization, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
end
