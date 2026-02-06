class ProfileView < ApplicationRecord
  belongs_to :viewable, polymorphic: true
  belongs_to :viewer, class_name: "User", optional: true

  validates :viewable_type, inclusion: { in: %w[DoctorProfile Establishment Supplier] }

  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }
  scope :this_week, -> { where("created_at >= ?", 1.week.ago) }
  scope :this_month, -> { where("created_at >= ?", 1.month.ago) }
end
