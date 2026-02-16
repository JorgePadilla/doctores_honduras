class CreateAppointmentNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :appointment_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.text :message, null: false
      t.boolean :read, null: false, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :appointment_notifications, [:user_id, :read]
  end
end
