class AddVideoConsultationUrlToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :video_consultation_url, :string
  end
end
