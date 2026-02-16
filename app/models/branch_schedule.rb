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

  DEFAULT_HOURS = {
    0 => { opens_at: nil, closes_at: nil, closed: true },
    1 => { opens_at: "08:00", closes_at: "17:00", closed: false },
    2 => { opens_at: "08:00", closes_at: "17:00", closed: false },
    3 => { opens_at: "08:00", closes_at: "17:00", closed: false },
    4 => { opens_at: "08:00", closes_at: "17:00", closed: false },
    5 => { opens_at: "08:00", closes_at: "17:00", closed: false },
    6 => { opens_at: "08:00", closes_at: "12:00", closed: false }
  }.freeze

  def day_name
    DAY_NAMES[day_of_week]
  end
end
