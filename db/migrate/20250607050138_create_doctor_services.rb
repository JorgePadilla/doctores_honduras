class CreateDoctorServices < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_services do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :doctor_services, [:doctor_profile_id, :service_id], unique: true, name: 'idx_unique_doctor_service'
  end
end
