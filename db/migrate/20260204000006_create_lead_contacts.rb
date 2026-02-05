class CreateLeadContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :lead_contacts do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :organization
      t.text :message
      t.string :status, default: "new"

      t.timestamps
    end
  end
end
