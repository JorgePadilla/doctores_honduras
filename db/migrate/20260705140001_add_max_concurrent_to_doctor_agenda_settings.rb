class AddMaxConcurrentToDoctorAgendaSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_agenda_settings, :max_concurrent, :integer, default: 1, null: false
  end
end
