class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    # The subscriptions table already exists, so we'll update it instead
    change_table :subscriptions do |t|
      # Add the new columns that don't exist in the current schema
      t.references :subscription_plan, foreign_key: true
      t.string :plan_name
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :cancel_at
      t.string :stripe_customer_id
      
      # Rename next_billing_at to current_period_end if it doesn't exist
      if column_exists?(:subscriptions, :next_billing_at) && !column_exists?(:subscriptions, :current_period_end)
        t.rename :next_billing_at, :current_period_end
      end
    end
  end
end
