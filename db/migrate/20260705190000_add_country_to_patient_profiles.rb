class AddCountryToPatientProfiles < ActiveRecord::Migration[8.0]
  def change
    # País del paciente (jerarquía país → departamento → ciudad). Nullable en BD
    # (filas existentes no lo tienen); obligatorio a nivel de modelo para altas.
    add_reference :patient_profiles, :country, null: true, foreign_key: true
  end
end
