class AddPhoneToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :phone, :string
  end
end
