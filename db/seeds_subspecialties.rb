# This seed file creates medical subespecialties
# Run with: rails runner db/seeds_subspecialties.rb

puts "Creating medical subespecialties..."

# Define subespecialties grouped by specialty
subspecialties_data = {
  "Cardiología" => [
    "Cardiología Intervencionista",
    "Electrofisiología",
    "Cardiología Pediátrica",
    "Insuficiencia Cardíaca",
    "Cardiología No Invasiva"
  ],
  "Pediatría" => [
    "Neonatología",
    "Neurología Pediátrica",
    "Cardiología Pediátrica",
    "Gastroenterología Pediátrica",
    "Nefrología Pediátrica",
    "Oncología Pediátrica"
  ],
  "Ginecología y Obstetricia" => [
    "Ginecología Oncológica",
    "Endocrinología Ginecológica",
    "Uroginecología",
    "Medicina Materno-Fetal",
    "Reproducción Humana"
  ],
  "Neurología" => [
    "Neurofisiología Clínica",
    "Neurología Vascular",
    "Epileptología",
    "Neurooncología",
    "Neurología del Dolor"
  ],
  "Ortopedia y Traumatología" => [
    "Cirugía de Mano",
    "Cirugía de Columna",
    "Artroscopia",
    "Traumatología Deportiva",
    "Cirugía de Cadera y Rodilla"
  ],
  "Oftalmología" => [
    "Retina",
    "Córnea",
    "Glaucoma",
    "Oftalmología Pediátrica",
    "Cirugía Plástica Ocular"
  ],
  "Gastroenterología" => [
    "Hepatología",
    "Endoscopia Digestiva",
    "Motilidad Digestiva",
    "Gastroenterología Oncológica"
  ],
  "Oncología" => [
    "Oncología Médica",
    "Oncología Radioterápica",
    "Hematología",
    "Oncología Pediátrica"
  ],
  "Psiquiatría" => [
    "Psiquiatría Infantil y Adolescente",
    "Psiquiatría Geriátrica",
    "Psiquiatría de Enlace",
    "Adicciones"
  ],
  "Dermatología" => [
    "Dermatología Oncológica",
    "Dermatología Pediátrica",
    "Dermatopatología",
    "Dermatología Estética"
  ],
  "Urología" => [
    "Urología Oncológica",
    "Urología Pediátrica",
    "Andrología",
    "Urología Funcional"
  ],
  "Cirugía General" => [
    "Cirugía Oncológica",
    "Cirugía Laparoscópica",
    "Cirugía de Tórax",
    "Cirugía Vascular"
  ]
}

created_count = 0
subspecialties_data.each do |specialty_name, subspecialty_names|
  specialty = Specialty.find_by(name: specialty_name)
  if specialty
    subspecialty_names.each do |subspecialty_name|
      subspecialty = Subspecialty.find_or_create_by!(
        name: subspecialty_name,
        specialty: specialty
      )
      created_count += 1
      puts "  - Created subespecialty: #{subspecialty_name} (#{specialty_name})"
    end
  else
    puts "  - Warning: Specialty '#{specialty_name}' not found"
  end
end

puts "Created #{created_count} subespecialties"