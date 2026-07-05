class AddWhatsappToDoctorProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :whatsapp, :string
  end
end
