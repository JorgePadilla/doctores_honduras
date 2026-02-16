class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :doctor_profile, null: false, foreign_key: true
      t.references :doctor_branch, null: false, foreign_key: true
      t.string :patient_name, null: false
      t.string :patient_phone
      t.string :patient_email
      t.date :appointment_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.string :status, null: false, default: "pendiente"
      t.text :reason
      t.text :doctor_notes
      t.string :booking_source, null: false, default: "manual"
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :appointments, [:doctor_branch_id, :appointment_date, :start_time], name: "idx_appointments_branch_date_time"
    add_index :appointments, [:doctor_profile_id, :appointment_date], name: "idx_appointments_doctor_date"
    add_index :appointments, :status
    add_index :appointments, :patient_email
  end
end
