class AddSubspecialtyToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :subspecialty, :string
  end
end
