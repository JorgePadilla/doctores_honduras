class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions
  
  # Campos:
  # - name (string)
  # - price (integer) - en centavos
  # - interval (string) - 'month' o 'year'
  # - features (text) - lista de características separadas por comas
  # - stripe_price_id (string) - ID del precio en Stripe
  # - stripe_product_id (string) - ID del producto en Stripe
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[month year] }

  scope :visible, -> { where(visible: true) }
  scope :hidden, -> { where(visible: false) }
  
  def display_price
    "#{price_in_dollars}/#{interval_display}"
  end
  
  def price_in_dollars
    "$#{(price / 100.0).round(2)}"
  end
  
  def interval_display
    interval == 'month' ? 'mes' : 'año'
  end
  
  # Stripe integration methods
  def create_or_update_stripe_product
    if stripe_product_id.present?
      # Update existing product
      product = Stripe::Product.update(
        stripe_product_id,
        { name: name, description: features }
      )
    else
      # Create new product
      product = Stripe::Product.create({
        name: name,
        description: features
      })
      
      # Save product ID
      update(stripe_product_id: product.id)
    end
    
    # Create or update price
    create_or_update_stripe_price(product.id)
    
    product
  end
  
  private
  
  def create_or_update_stripe_price(product_id)
    # Stripe prices cannot be updated, so we always create a new one
    # and update our reference
    
    # Create new price
    price = Stripe::Price.create({
      product: product_id,
      unit_amount: self.price,
      currency: 'usd',
      recurring: { interval: self.interval }
    })
    
    # Save price ID
    update(stripe_price_id: price.id)
    
    price
  end
end
