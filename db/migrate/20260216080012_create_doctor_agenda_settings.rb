class CreateDoctorAgendaSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_agenda_settings do |t|
      t.references :doctor_profile, null: false, foreign_key: true, index: { unique: true }
      t.integer :appointment_duration, null: false, default: 30
      t.integer :buffer_minutes, null: false, default: 0
      t.boolean :public_booking_enabled, null: false, default: false

      t.timestamps
    end
  end
end
