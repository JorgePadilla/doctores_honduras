class DoctorBranch < ApplicationRecord
  belongs_to :doctor_profile
  belongs_to :department, optional: true
  belongs_to :city, optional: true
  has_many :branch_schedules, dependent: :destroy
  has_many :appointments, dependent: :destroy

  accepts_nested_attributes_for :branch_schedules, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :address, presence: true

  scope :ordered, -> { order(:position) }
end
