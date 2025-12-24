# This script creates specialties and services and associates them with establishments
# Run with: rails runner db/seed_specialties_services.rb

# Create specialties
puts "Creating specialties..."
specialties = [
  "Ortodoncia",
  "Nutrición",
  "Pediatría",
  "Psicología-Podiatría",
  "Medicina Estética",
  "Laparoscopía",
  "Ortopedia y Traumatología",
  "Ginecología",
  "Dermatología",
  "Cardiología",
  "Oftalmología",
  "Neurología",
  "Endocrinología"
]

created_specialties = []
specialties.each do |name|
  specialty = Specialty.find_or_create_by!(name: name)
  created_specialties << specialty
end

puts "Created #{Specialty.count} specialties"

# Create services
puts "Creating services..."
services = [
  "Farmacia",
  "Medicina General a recién nacido, niños, adulto y tercera edad",
  "Extracciones / Restauraciones",
  "Examen de Citología",
  "Lesiones que afectan los músculos, huesos y articulaciones",
  "Ultrasonidos",
  "Tratamiento Faciales y Corporales",
  "Trombosis venosa",
  "Prevención de pie Diabético",
  "Atención a mujer embarazada",
  "Radiografías",
  "Limpiezas dentales",
  "Control de peso (Obesidad y Desnutrición)",
  "Enfermedades Pulmonares",
  "Fracturas en Huesos",
  "Evaluaciones psicológicas",
  "Estimulación temprana",
  "Laboratorio",
  "Terapia Física y Rehabilitación"
]

created_services = []
services.each do |name|
  service = Service.find_or_create_by!(name: name)
  created_services << service
end

puts "Created #{Service.count} services"

# Associate specialties and services with establishments
puts "Associating specialties and services with establishments..."

# Get all establishments
establishments = Establishment.all
puts "Found #{establishments.count} establishments"

# Associate specialties and services with the first establishment (Centro Médico Rosales)
if establishments.any?
  centro_medico = establishments.first
  puts "Associating specialties and services with #{centro_medico.name}"
  
  centro_medico_specialties = ["Ortodoncia", "Nutrición", "Pediatría", "Psicología-Podiatría", "Medicina Estética", "Laparoscopía", "Ortopedia y Traumatología"]
  centro_medico_services = [
    "Farmacia", 
    "Medicina General a recién nacido, niños, adulto y tercera edad", 
    "Extracciones / Restauraciones", 
    "Examen de Citología", 
    "Lesiones que afectan los músculos, huesos y articulaciones", 
    "Ultrasonidos", 
    "Tratamiento Faciales y Corporales", 
    "Trombosis venosa", 
    "Prevención de pie Diabético", 
    "Atención a mujer embarazada", 
    "Radiografías", 
    "Limpiezas dentales", 
    "Control de peso (Obesidad y Desnutrición)", 
    "Enfermedades Pulmonares", 
    "Fracturas en Huesos", 
    "Evaluaciones psicológicas", 
    "Estimulación temprana", 
    "Laboratorio", 
    "Terapia Física y Rehabilitación"
  ]

  centro_medico_specialties.each do |specialty_name|
    specialty = Specialty.find_by(name: specialty_name)
    if specialty
      EstablishmentSpecialty.find_or_create_by!(establishment: centro_medico, specialty: specialty)
      puts "  - Added specialty: #{specialty_name}"
    end
  end

  centro_medico_services.each do |service_name|
    service = Service.find_by(name: service_name)
    if service
      EstablishmentService.find_or_create_by!(establishment: centro_medico, service: service)
      puts "  - Added service: #{service_name}"
    end
  end

  # For other establishments, assign random specialties and services
  establishments[1..].each_with_index do |establishment, index|
    puts "Associating specialties and services with #{establishment.name}"
    
    # Assign 3-7 random specialties
    num_specialties = rand(3..7)
    establishment_specialties = created_specialties.sample(num_specialties)
    
    establishment_specialties.each do |specialty|
      EstablishmentSpecialty.find_or_create_by!(establishment: establishment, specialty: specialty)
      puts "  - Added specialty: #{specialty.name}"
    end
    
    # Assign 5-10 random services
    num_services = rand(5..10)
    establishment_services = created_services.sample(num_services)
    
    establishment_services.each do |service|
      EstablishmentService.find_or_create_by!(establishment: establishment, service: service)
      puts "  - Added service: #{service.name}"
    end
  end
end

puts "Specialties and services associated with establishments"
