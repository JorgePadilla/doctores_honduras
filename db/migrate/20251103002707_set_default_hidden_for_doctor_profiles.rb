class SetDefaultHiddenForDoctorProfiles < ActiveRecord::Migration[8.0]
  def up
    # Set default value for new records
    change_column_default :doctor_profiles, :hidden, false

    # Update existing records where hidden is NULL to false
    DoctorProfile.where(hidden: nil).update_all(hidden: false)
  end

  def down
    # Remove default value
    change_column_default :doctor_profiles, :hidden, nil

    # We cannot easily revert the data changes, but this is acceptable
    # since the migration is fixing a data issue
  end
end
