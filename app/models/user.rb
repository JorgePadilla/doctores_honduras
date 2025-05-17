class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_many :payment_histories, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :language, inclusion: { in: %w[es en], allow_nil: true }
  
  # Valores predeterminados
  attribute :language, :string, default: 'es'
  
  def active_subscription?
    subscription.present? && subscription.active?
  end
  
  def subscription_plan_name
    active_subscription? ? subscription.plan_name : 'Gratuito'
  end
  
  def two_factor_enabled?
    two_factor_secret.present?
  end
end
