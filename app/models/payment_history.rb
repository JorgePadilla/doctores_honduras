class PaymentHistory < ApplicationRecord
  belongs_to :user
  
  # Campos disponibles:
  # - amount (integer) - en centavos
  # - status (string) - 'completed', 'failed', 'pending'
  # - payment_method (string) - 'tarjeta', 'transferencia', etc.
  # - description (text)
  
  validates :user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  
  def amount_in_dollars
    "$#{sprintf('%.2f', amount / 100.0)}"
  end
  
  def formatted_payment_date
    payment_date.strftime("%d/%m/%Y %H:%M")
  end
end
