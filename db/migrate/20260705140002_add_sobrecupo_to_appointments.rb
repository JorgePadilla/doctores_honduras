class AddSobrecupoToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :sobrecupo, :boolean, default: false, null: false
  end
end
