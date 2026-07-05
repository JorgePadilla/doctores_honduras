class Prescription < ApplicationRecord
  belongs_to :appointment
  has_many :prescription_items, dependent: :destroy
  delegate :patient, :doctor_profile, to: :appointment

  accepts_nested_attributes_for :prescription_items, allow_destroy: true,
    reject_if: ->(attrs) { attrs[:medication].blank? }

  def any_items?
    prescription_items.any?
  end
end
