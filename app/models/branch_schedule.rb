class BranchSchedule < ApplicationRecord
  belongs_to :doctor_branch

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :opens_at, presence: true
  validates :closes_at, presence: true

  DAY_NAMES = {
    0 => "Domingo",
    1 => "Lunes",
    2 => "Martes",
    3 => "Miércoles",
    4 => "Jueves",
    5 => "Viernes",
    6 => "Sábado"
  }.freeze

  def day_name
    DAY_NAMES[day_of_week]
  end
end
