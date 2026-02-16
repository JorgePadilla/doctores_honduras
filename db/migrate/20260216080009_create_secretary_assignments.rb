class CreateSecretaryAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :secretary_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :doctor_profile, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.string :invitation_token
      t.datetime :invitation_accepted_at
      t.string :invited_email

      t.timestamps
    end

    add_index :secretary_assignments, [:user_id, :doctor_profile_id], unique: true
    add_index :secretary_assignments, :invitation_token, unique: true
  end
end
