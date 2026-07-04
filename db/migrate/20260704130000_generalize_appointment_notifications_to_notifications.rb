class GeneralizeAppointmentNotificationsToNotifications < ActiveRecord::Migration[8.0]
  def up
    rename_table :appointment_notifications, :notifications

    add_column :notifications, :title, :string
    add_column :notifications, :url, :string
    add_column :notifications, :icon, :string
    add_reference :notifications, :notifiable, polymorphic: true, index: true

    # Backfill the existing appointment notifications into the polymorphic shape.
    klass = Class.new(ActiveRecord::Base) { self.table_name = "notifications" }
    url_helpers = Rails.application.routes.url_helpers
    klass.where.not(appointment_id: nil).find_each do |n|
      n.update_columns(
        notifiable_type: "Appointment",
        notifiable_id: n.appointment_id,
        url: url_helpers.agenda_appointment_path(n.appointment_id),
        icon: "calendar_days",
        title: (n.notification_type == "nueva_cita" ? "Nueva cita" : "Cambio de cita")
      )
    end

    remove_foreign_key :notifications, :appointments if foreign_key_exists?(:notifications, :appointments)
    remove_column :notifications, :appointment_id
  end

  def down
    add_reference :notifications, :appointment, null: true, foreign_key: true

    klass = Class.new(ActiveRecord::Base) { self.table_name = "notifications" }
    klass.where(notifiable_type: "Appointment").find_each do |n|
      n.update_columns(appointment_id: n.notifiable_id)
    end

    remove_reference :notifications, :notifiable, polymorphic: true, index: true
    remove_column :notifications, :title
    remove_column :notifications, :url
    remove_column :notifications, :icon
    rename_table :notifications, :appointment_notifications
  end
end
