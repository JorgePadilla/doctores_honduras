class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[month year] }

  scope :for_profile_type, ->(type) { where(profile_type: type) }
  scope :ordered, -> { order(:position) }

  def display_price
    "#{price_in_dollars}/#{interval_display}"
  end

  def price_in_dollars
    "$#{(price / 100.0).round(2)}"
  end

  def interval_display
    interval == "month" ? "mes" : "año"
  end

  def free?
    price == 0
  end

  # Stripe integration methods
  def create_or_update_stripe_product
    if stripe_product_id.present?
      product = Stripe::Product.update(
        stripe_product_id,
        { name: name, description: features }
      )
    else
      product = Stripe::Product.create({
        name: name,
        description: features
      })

      update(stripe_product_id: product.id)
    end

    create_or_update_stripe_price(product.id)

    product
  end

  private

  def create_or_update_stripe_price(product_id)
    price = Stripe::Price.create({
      product: product_id,
      unit_amount: self.price,
      currency: "usd",
      recurring: { interval: self.interval }
    })

    update(stripe_price_id: price.id)

    price
  end
end
