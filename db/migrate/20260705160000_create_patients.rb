class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.date :date_of_birth

      t.timestamps
    end

    # Un paciente registrado (con cuenta) es único por médico.
    add_index :patients, [ :doctor_profile_id, :user_id ], unique: true,
      where: "user_id IS NOT NULL", name: "idx_patients_doctor_user_unique"
  end
end
