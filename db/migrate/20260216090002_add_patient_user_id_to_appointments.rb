class AddPatientUserIdToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :appointments, :patient_user, foreign_key: { to_table: :users }, null: true
  end
end
