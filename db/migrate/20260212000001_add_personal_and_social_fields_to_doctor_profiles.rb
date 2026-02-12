class AddPersonalAndSocialFieldsToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :fecha_de_nacimiento, :date
    add_column :doctor_profiles, :numero_de_identidad, :string
    add_column :doctor_profiles, :correo_personal, :string
    add_column :doctor_profiles, :facebook_url, :string
    add_column :doctor_profiles, :instagram_url, :string
    add_column :doctor_profiles, :twitter_url, :string
    add_column :doctor_profiles, :linkedin_url, :string
    add_column :doctor_profiles, :tiktok_url, :string
    add_column :doctor_profiles, :youtube_url, :string
    add_column :doctor_profiles, :languages, :text, array: true, default: []
  end
end
