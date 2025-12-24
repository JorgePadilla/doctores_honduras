class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :email_notifications
      t.boolean :marketing_emails
      t.boolean :new_features_notifications
      t.boolean :security_alerts

      t.timestamps
    end
  end
end
