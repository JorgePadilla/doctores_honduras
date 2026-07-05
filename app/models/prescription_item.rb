class PrescriptionItem < ApplicationRecord
  belongs_to :prescription

  validates :medication, presence: true

  # "Amoxicilina · 500mg · cada 8 horas · 7 días"
  def summary_line
    [ medication, dosage, frequency, duration ].compact_blank.join(" · ")
  end
end
