class AddHiddenToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :hidden, :boolean
  end
end
