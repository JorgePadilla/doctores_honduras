class AddProfileTypeAndTierToSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :subscription_plans, :profile_type, :string
    add_column :subscription_plans, :tier, :string
    add_column :subscription_plans, :position, :integer, default: 0
    add_index :subscription_plans, [ :profile_type, :tier ], unique: true
  end
end
