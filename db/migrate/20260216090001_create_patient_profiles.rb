class CreatePatientProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.string :phone
      t.date :date_of_birth
      t.references :department, foreign_key: true
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
