class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # Skip creating users table as it already exists
    # Instead, add a unique index on email if it doesn't exist
    unless index_exists?(:users, :email)
      add_index :users, :email, unique: true
    end
  end
end
