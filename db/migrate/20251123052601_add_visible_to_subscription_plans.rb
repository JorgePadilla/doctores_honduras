class AddVisibleToSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :subscription_plans, :visible, :boolean
  end
end
