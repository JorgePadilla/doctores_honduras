class AddPatientToAppointments < ActiveRecord::Migration[8.0]
  # Vincula las citas a la identidad canónica del paciente (Patient), migrando
  # desde los campos actuales (patient_user_id / patient_name). Se conservan
  # patient_name/patient_user_id por compatibilidad; el código nuevo usa patient.
  def up
    add_reference :appointments, :patient, null: true, foreign_key: true, index: true

    # 1) Pacientes registrados: uno por (médico, user).
    execute <<~SQL
      INSERT INTO patients (doctor_profile_id, user_id, name, phone, email, created_at, updated_at)
      SELECT DISTINCT ON (doctor_profile_id, patient_user_id)
             doctor_profile_id, patient_user_id, patient_name, patient_phone, patient_email, NOW(), NOW()
      FROM appointments
      WHERE patient_user_id IS NOT NULL
      ORDER BY doctor_profile_id, patient_user_id, created_at DESC;
    SQL

    # 2) Walk-ins (sin cuenta): uno por (médico, nombre normalizado).
    execute <<~SQL
      INSERT INTO patients (doctor_profile_id, name, phone, email, created_at, updated_at)
      SELECT DISTINCT ON (doctor_profile_id, lower(btrim(patient_name)))
             doctor_profile_id, patient_name, patient_phone, patient_email, NOW(), NOW()
      FROM appointments
      WHERE patient_user_id IS NULL
      ORDER BY doctor_profile_id, lower(btrim(patient_name)), created_at DESC;
    SQL

    # 3) Enlaza las citas de pacientes registrados.
    execute <<~SQL
      UPDATE appointments a SET patient_id = p.id
      FROM patients p
      WHERE p.doctor_profile_id = a.doctor_profile_id
        AND p.user_id = a.patient_user_id
        AND a.patient_user_id IS NOT NULL;
    SQL

    # 4) Enlaza las citas de walk-ins por nombre normalizado.
    execute <<~SQL
      UPDATE appointments a SET patient_id = p.id
      FROM patients p
      WHERE p.doctor_profile_id = a.doctor_profile_id
        AND p.user_id IS NULL
        AND lower(btrim(p.name)) = lower(btrim(a.patient_name))
        AND a.patient_user_id IS NULL;
    SQL
  end

  def down
    remove_reference :appointments, :patient, foreign_key: true
  end
end
