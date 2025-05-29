class AddSubspecialtiesToDoctors < ActiveRecord::Migration[8.0]
  def up
    # Add subspecialties to some doctors
    execute <<-SQL
      UPDATE doctor_profiles SET subspecialty = 'Manejo del Dolor Crónico' WHERE name = 'Dr. Luis Martínez Arita';
      UPDATE doctor_profiles SET subspecialty = 'Terapia Cognitivo-Conductual' WHERE name = 'Dra. Ana Alvarez Mendoza';
      UPDATE doctor_profiles SET subspecialty = 'Cardiología Intervencionista' WHERE specialization = 'Cardiología' LIMIT 2;
      UPDATE doctor_profiles SET subspecialty = 'Neurología Pediátrica' WHERE specialization = 'Pediatría' LIMIT 2;
      UPDATE doctor_profiles SET subspecialty = 'Medicina Materno Fetal' WHERE specialization = 'Ginecología' LIMIT 2;
      UPDATE doctor_profiles SET subspecialty = 'Ortopedia Oncológica' WHERE specialization = 'Ortopedia' LIMIT 2;
      UPDATE doctor_profiles SET subspecialty = 'Neurología Vascular' WHERE specialization = 'Neurología' LIMIT 2;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE doctor_profiles SET subspecialty = NULL;
    SQL
  end
end
