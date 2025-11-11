# This seed file creates medical specialties
# Run with: rails runner db/seeds_specialties.rb

puts "Creating medical specialties..."

specialties = [
  "Medicina General",
  "Pediatría",
  "Ginecología y Obstetricia",
  "Cardiología",
  "Dermatología",
  "Ortopedia y Traumatología",
  "Oftalmología",
  "Otorrinolaringología",
  "Neurología",
  "Psiquiatría",
  "Endocrinología",
  "Gastroenterología",
  "Nefrología",
  "Urología",
  "Oncología",
  "Reumatología",
  "Alergología",
  "Medicina Interna",
  "Cirugía General",
  "Anestesiología",
  "Radiología",
  "Medicina Familiar",
  "Medicina del Deporte",
  "Medicina del Trabajo",
  "Medicina Estética",
  "Nutrición",
  "Odontología",
  "Ortodoncia",
  "Periodoncia",
  "Cirugía Maxilofacial"
]

created_specialties = []
specialties.each do |name|
  specialty = Specialty.find_or_create_by!(name: name)
  created_specialties << specialty
  puts "  - Created specialty: #{name}"
end

puts "Created #{Specialty.count} specialties"