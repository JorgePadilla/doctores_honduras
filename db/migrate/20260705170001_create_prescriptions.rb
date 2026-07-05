class CreatePrescriptions < ActiveRecord::Migration[8.0]
  # Receta / prescripción de una consulta (H2). Una por cita; con indicaciones
  # generales y varios medicamentos (prescription_items).
  def change
    create_table :prescriptions do |t|
      t.references :appointment, null: false, foreign_key: true, index: { unique: true }
      t.text :instructions

      t.timestamps
    end
  end
end
