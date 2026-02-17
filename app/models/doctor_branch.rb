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

  # Auto-create default schedules (Mon-Sat) if the branch has none.
  # Similar pattern to DoctorAgendaSetting auto-build in SlotGenerator.
  def ensure_default_schedules!
    return if branch_schedules.any?

    BranchSchedule::DEFAULT_HOURS.each do |day_num, defaults|
      next if defaults[:closed]

      branch_schedules.create!(
        day_of_week: day_num,
        opens_at: defaults[:opens_at],
        closes_at: defaults[:closes_at]
      )
    end
  end
end
