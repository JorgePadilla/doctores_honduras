class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.text :description
      t.integer :price
      t.string :interval
      t.text :features
      t.string :stripe_price_id

      t.timestamps
    end
  end
end
