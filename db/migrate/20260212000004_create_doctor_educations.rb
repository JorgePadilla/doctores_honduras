class CreateDoctorEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_educations do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.string :institution, null: false
      t.string :degree
      t.integer :graduation_year
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
