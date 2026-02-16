class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_many :payment_histories, dependent: :destroy
  has_one :doctor_profile, dependent: :destroy
  has_many :establishments, dependent: :destroy
  has_many :secretary_assignments, dependent: :destroy
  has_many :managed_doctor_profiles, through: :secretary_assignments, source: :doctor_profile
  has_many :appointment_notifications, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :language, inclusion: { in: %w[es en], allow_nil: true }
  validates :profile_type, inclusion: { in: %w[doctor hospital clinic vendor paciente], allow_nil: true }
  has_one :supplier, dependent: :destroy
  has_one :patient_profile, dependent: :destroy
  has_many :patient_appointments, class_name: "Appointment", foreign_key: :patient_user_id
  
  # Valores predeterminados
  attribute :language, :string, default: 'es'
  attribute :onboarding_completed, :boolean, default: false
  
  def active_subscription?
    subscription.present? && subscription.active?
  end
  
  def subscription_plan_name
    active_subscription? ? subscription.plan_name : 'Gratuito'
  end
  
  def two_factor_enabled?
    two_factor_secret.present?
  end
  
  def profile_complete?
    case profile_type
    when 'doctor'
      doctor_profile.present? && doctor_profile.valid?
    when 'hospital', 'clinic'
      establishments.exists?
    when 'vendor'
      supplier.present?
    when 'paciente'
      patient_profile.present?
    else
      false
    end
  end

  def admin?
    admin.present? && admin
  end

  def secretary?
    secretary_assignments.active.exists?
  end

  def secretary_for?(doctor_profile)
    secretary_assignments.active.for_doctor(doctor_profile).exists?
  end

  def unread_notifications_count
    appointment_notifications.unread.count
  end
end
