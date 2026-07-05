class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[month year] }
  validates :patient_limit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # Los precios en Stripe son inmutables: si cambia el monto, hay que generar un
  # Price nuevo. Al invalidar el stripe_price_id guardado, el próximo checkout
  # (StripeController) recrea el Price al monto correcto en vez de cobrar el viejo.
  before_save :reset_stripe_price_on_amount_change

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

  # Los planes Elite incluyen el Expediente Clínico Digital, con un techo de
  # registros (pacientes) que define patient_limit. Sin límite = la función no
  # aplica al plan.
  def patient_limit?
    patient_limit.present?
  end

  # Texto listo para UI: "Hasta 5,000 registros clínicos".
  def patient_limit_label
    return unless patient_limit?

    "Hasta #{ActiveSupport::NumberHelper.number_to_delimited(patient_limit, delimiter: ',')} registros clínicos"
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

  def reset_stripe_price_on_amount_change
    self.stripe_price_id = nil if persisted? && price_changed?
  end

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
