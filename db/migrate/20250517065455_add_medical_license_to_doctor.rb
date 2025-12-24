class AddMedicalLicenseToDoctor < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :medical_license, :string
  end
end
