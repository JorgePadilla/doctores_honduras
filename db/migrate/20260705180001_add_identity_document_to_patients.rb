class AddIdentityDocumentToPatients < ActiveRecord::Migration[8.0]
  def change
    # DNI en el registro canónico del paciente (lado del médico). Opcional: se
    # llena desde el PatientProfile del paciente registrado, o queda vacío para
    # walk-ins.
    add_column :patients, :identity_document, :string
    add_index :patients, [ :doctor_profile_id, :identity_document ]
  end
end
