class CreateClinicalRecords < ActiveRecord::Migration[8.0]
  def change
    # Ficha clínica: una por paciente (el paciente ya es por-médico, así que el
    # scope del expediente lo hereda vía patient.doctor_profile).
    create_table :clinical_records do |t|
      t.references :patient, null: false, foreign_key: true, index: { unique: true }
      t.text :allergies
      t.text :chronic_conditions
      t.text :current_medications
      t.string :blood_type
      t.text :medical_history
      t.text :notes

      t.timestamps
    end
  end
end
