class AddIdentityDocumentToPatientProfiles < ActiveRecord::Migration[8.0]
  def change
    # Número de identidad (DNI Honduras, 13 dígitos). Nullable a nivel de BD
    # (filas existentes no lo tienen); obligatorio a nivel de modelo para altas.
    add_column :patient_profiles, :identity_document, :string
    add_index :patient_profiles, :identity_document
  end
end
