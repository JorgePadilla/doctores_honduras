class AddPrefixToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :prefix, :string
  end
end
