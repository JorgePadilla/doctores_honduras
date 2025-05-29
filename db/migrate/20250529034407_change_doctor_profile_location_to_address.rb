class ChangeDoctorProfileLocationToAddress < ActiveRecord::Migration[8.0]
  def change
    # Rename location to address
    rename_column :doctor_profiles, :location, :address
    
    # Add city and state columns
    add_column :doctor_profiles, :city, :string
    add_column :doctor_profiles, :state, :string
  end
end
