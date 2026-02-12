class FixHiddenDefaultOnDoctorProfiles < ActiveRecord::Migration[8.0]
  def up
    change_column_default :doctor_profiles, :hidden, false
    change_column_null :doctor_profiles, :hidden, false, false
  end

  def down
    change_column_null :doctor_profiles, :hidden, true
    change_column_default :doctor_profiles, :hidden, nil
  end
end
