class CreateEncounters < ActiveRecord::Migration[8.0]
  # Documentación clínica de una consulta (H1 nota de evolución + H3 signos
  # vitales). Una por cita. La nota de evolución es interna del médico; los
  # signos vitales sí se muestran al paciente (I1).
  def change
    create_table :encounters do |t|
      t.references :appointment, null: false, foreign_key: true, index: { unique: true }
      t.text :evolution_note
      t.string :blood_pressure
      t.integer :heart_rate
      t.decimal :temperature, precision: 4, scale: 1
      t.integer :respiratory_rate
      t.integer :oxygen_saturation
      t.decimal :weight, precision: 5, scale: 2
      t.decimal :height, precision: 5, scale: 2

      t.timestamps
    end
  end
end
