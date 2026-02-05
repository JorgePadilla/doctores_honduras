class LeadContact < ApplicationRecord
  belongs_to :supplier

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[new contacted converted] }

  scope :recent, -> { order(created_at: :desc) }
end
