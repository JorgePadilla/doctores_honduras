class RemoveCityFromDoctorProfiles < ActiveRecord::Migration[8.0]
  def up
    remove_column :doctor_profiles, :city
  end

  def down
    add_column :doctor_profiles, :city, :string
  end
end
