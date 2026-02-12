class CreateDoctorBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_branches do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address, null: false
      t.references :department, foreign_key: true
      t.references :city, foreign_key: true
      t.string :map_link
      t.string :phone
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
