class RemoveSpecializationFromDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :doctor_profiles, :specialization, :string
  end
end
