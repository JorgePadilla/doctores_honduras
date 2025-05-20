class AddStripeFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    # Add Stripe fields to subscriptions if they don't exist
    unless column_exists?(:subscriptions, :stripe_subscription_id)
      add_column :subscriptions, :stripe_subscription_id, :string
    end
    
    unless column_exists?(:subscriptions, :stripe_customer_id)
      add_column :subscriptions, :stripe_customer_id, :string
    end
    
    unless column_exists?(:subscriptions, :cancel_at)
      add_column :subscriptions, :cancel_at, :datetime
    end
    
    # Add Stripe fields to subscription plans if they don't exist
    unless column_exists?(:subscription_plans, :stripe_product_id)
      add_column :subscription_plans, :stripe_product_id, :string
    end
    
    unless column_exists?(:subscription_plans, :stripe_price_id)
      add_column :subscription_plans, :stripe_price_id, :string
    end
    
    # Add indexes for faster lookups
    add_index :subscriptions, :stripe_subscription_id, unique: true, if_not_exists: true
    add_index :subscriptions, :stripe_customer_id, if_not_exists: true
    add_index :subscription_plans, :stripe_product_id, unique: true, if_not_exists: true
    add_index :subscription_plans, :stripe_price_id, unique: true, if_not_exists: true
  end
end
