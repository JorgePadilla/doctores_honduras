class CreateDoctorCertifications < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_certifications do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.string :name, null: false
      t.string :institution
      t.integer :year
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
