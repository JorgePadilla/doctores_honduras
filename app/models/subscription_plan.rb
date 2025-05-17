class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[month year] }
  
  def display_price
    "#{price_in_dollars}/#{interval_display}"
  end
  
  def price_in_dollars
    "$#{(price / 100.0).round(2)}"
  end
  
  def interval_display
    interval == 'month' ? 'mes' : 'año'
  end
end
