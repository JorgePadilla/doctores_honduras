class AddSubspecialtyIdToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :doctor_profiles, :subspecialty, null: true, foreign_key: true
  end
end
