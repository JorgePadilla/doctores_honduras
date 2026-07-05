class ClinicalRecord < ApplicationRecord
  belongs_to :patient

  delegate :doctor_profile, to: :patient

  BLOOD_TYPES = %w[A+ A- B+ B- AB+ AB- O+ O-].freeze

  validates :blood_type, inclusion: { in: BLOOD_TYPES }, allow_blank: true

  def allergies?
    allergies.present?
  end

  # Una ficha sin ningún dato clínico cargado todavía.
  def blank_record?
    [ allergies, chronic_conditions, current_medications, blood_type, medical_history, notes ].all?(&:blank?)
  end
end
