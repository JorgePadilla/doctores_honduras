class AddProfileTypeAndOnboardingCompletedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_type, :string, default: nil
    add_column :users, :onboarding_completed, :boolean, default: false
  end
end
