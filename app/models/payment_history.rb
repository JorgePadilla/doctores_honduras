class PaymentHistory < ApplicationRecord
  belongs_to :user
  
  # Campos sugeridos:
  # - amount (integer) - en centavos
  # - currency (string) - 'usd', 'eur', etc.
  # - status (string) - 'succeeded', 'failed', 'pending'
  # - payment_method (string) - 'card', 'bank_transfer', etc.
  # - description (string)
  # - stripe_payment_id (string)
  # - payment_date (datetime)
  
  validates :user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :status, presence: true
  
  def amount_in_dollars
    "$#{(amount / 100.0).round(2)}"
  end
  
  def formatted_payment_date
    payment_date.strftime("%d/%m/%Y %H:%M")
  end
end
