class AddTwoFactorSecretToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :two_factor_secret, :string
  end
end
