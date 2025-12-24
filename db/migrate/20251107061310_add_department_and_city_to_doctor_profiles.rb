class AddDepartmentAndCityToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :doctor_profiles, :department, null: true, foreign_key: true
    add_reference :doctor_profiles, :city, null: true, foreign_key: true
  end
end
