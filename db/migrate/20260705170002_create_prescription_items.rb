class CreatePrescriptionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :prescription_items do |t|
      t.references :prescription, null: false, foreign_key: true
      t.string :medication, null: false
      t.string :dosage
      t.string :frequency
      t.string :duration

      t.timestamps
    end
  end
end
