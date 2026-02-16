class Appointment < ApplicationRecord
  belongs_to :doctor_profile
  belongs_to :doctor_branch
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :patient_user, class_name: "User", optional: true

  has_many :appointment_notifications, dependent: :destroy

  STATUSES = %w[pendiente confirmada cancelada completada].freeze
  BOOKING_SOURCES = %w[manual public_booking].freeze

  validates :patient_name, presence: true
  validates :appointment_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :booking_source, inclusion: { in: BOOKING_SOURCES }
  validate :end_time_after_start_time
  validate :within_branch_schedule, on: :create
  validate :no_overlapping_appointments, on: :create

  scope :for_date, ->(date) { where(appointment_date: date) }
  scope :for_branch, ->(branch) { where(doctor_branch: branch) }
  scope :for_week, ->(date) {
    start_of_week = date.beginning_of_week
    end_of_week = date.end_of_week
    where(appointment_date: start_of_week..end_of_week)
  }
  scope :upcoming, -> { where("appointment_date > ? OR (appointment_date = ? AND start_time > ?)", Date.current, Date.current, Time.current) }
  scope :active, -> { where.not(status: "cancelada") }
  scope :by_status, ->(status) { where(status: status) }

  def pendiente?
    status == "pendiente"
  end

  def confirmada?
    status == "confirmada"
  end

  def cancelada?
    status == "cancelada"
  end

  def completada?
    status == "completada"
  end

  def duration_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 60).to_i
  end

  STATUS_CLASSES = {
    "pendiente" => {
      dot: "bg-yellow-500",
      border: "border-yellow-400 dark:border-yellow-500",
      bg: "bg-yellow-100 dark:bg-yellow-900/30",
      text: "text-yellow-800 dark:text-yellow-300",
      week_card: "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300 hover:opacity-80"
    },
    "confirmada" => {
      dot: "bg-blue-500",
      border: "border-blue-400 dark:border-blue-500",
      bg: "bg-blue-100 dark:bg-blue-900/30",
      text: "text-blue-800 dark:text-blue-300",
      week_card: "bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 hover:opacity-80"
    },
    "cancelada" => {
      dot: "bg-red-500",
      border: "border-red-400 dark:border-red-500",
      bg: "bg-red-100 dark:bg-red-900/30",
      text: "text-red-800 dark:text-red-300",
      week_card: "bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300 hover:opacity-80"
    },
    "completada" => {
      dot: "bg-green-500",
      border: "border-green-400 dark:border-green-500",
      bg: "bg-green-100 dark:bg-green-900/30",
      text: "text-green-800 dark:text-green-300",
      week_card: "bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 hover:opacity-80"
    }
  }.freeze

  DEFAULT_STATUS_CLASSES = {
    dot: "bg-gray-500",
    border: "border-gray-400 dark:border-gray-500",
    bg: "bg-gray-100 dark:bg-gray-900/30",
    text: "text-gray-800 dark:text-gray-300",
    week_card: "bg-gray-100 dark:bg-gray-900/30 text-gray-800 dark:text-gray-300 hover:opacity-80"
  }.freeze

  def status_classes
    STATUS_CLASSES[status] || DEFAULT_STATUS_CLASSES
  end

  def status_label
    status.capitalize
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, "debe ser posterior a la hora de inicio") if end_time <= start_time
  end

  def within_branch_schedule
    return unless doctor_branch && appointment_date && start_time && end_time

    day = appointment_date.wday
    schedule = doctor_branch.branch_schedules.find_by(day_of_week: day)

    unless schedule
      errors.add(:appointment_date, "no hay horario configurado para este día")
      return
    end

    unless start_time >= schedule.opens_at && end_time <= schedule.closes_at
      errors.add(:start_time, "fuera del horario de atención (#{schedule.opens_at.strftime('%H:%M')} - #{schedule.closes_at.strftime('%H:%M')})")
    end
  end

  def no_overlapping_appointments
    return unless doctor_branch && appointment_date && start_time && end_time

    overlapping = Appointment.active
      .for_branch(doctor_branch)
      .for_date(appointment_date)
      .where("start_time < ? AND end_time > ?", end_time, start_time)

    overlapping = overlapping.where.not(id: id) if persisted?

    if overlapping.exists?
      errors.add(:start_time, "ya existe una cita en este horario")
    end
  end
end
