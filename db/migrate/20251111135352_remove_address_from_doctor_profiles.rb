class RemoveAddressFromDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :doctor_profiles, :address, :string
  end
end
