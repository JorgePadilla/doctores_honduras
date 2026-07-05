class Encounter < ApplicationRecord
  belongs_to :appointment
  delegate :patient, :doctor_profile, to: :appointment

  VITAL_FIELDS = %i[blood_pressure heart_rate temperature respiratory_rate oxygen_saturation weight height].freeze

  validates :heart_rate, :respiratory_rate, :oxygen_saturation,
    numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :oxygen_saturation, numericality: { less_than_or_equal_to: 100 }, allow_nil: true
  validates :temperature, :weight, :height,
    numericality: { greater_than: 0 }, allow_nil: true

  def vitals?
    VITAL_FIELDS.any? { |f| public_send(f).present? }
  end

  # Hay algo documentado (nota o vitales)?
  def any_data?
    vitals? || evolution_note.present?
  end
end
