# Medical services/tags for doctors in Honduras
services = [
  # Gastroenterology services
  "Endoscopia Diagnóstica y Terapéutica",
  "Gastroenterología",
  "Enfermedades del Aparato Digestivo",
  "Cáncer de Colon",
  "Coloproctología",
  "Enfermedades y Cirugía de Colon, Recto y Ano",
  
  # Surgical services
  "Cirugía General",
  "Cirugía Laparoscópica Básica",
  "Cirugía Menor dentro del Consultorio",
  
  # Specific conditions and treatments
  "Pólipos",
  "Enfermedades Hemorroidarias",
  "Abscesos",
  "Fístulas",
  "Fisuras",
  "Enfermedades Inflamatorias",
  
  # Diagnostic procedures
  "Estudios Endoscópicos Bajos",
  "Colonoscopia",
  "Polipectomía",
  
  # Other common medical specialties
  "Cardiología",
  "Dermatología",
  "Endocrinología",
  "Ginecología y Obstetricia",
  "Medicina Interna",
  "Neurología",
  "Oftalmología",
  "Ortopedia",
  "Pediatría",
  "Psiquiatría",
  "Urología",
  
  # Common procedures
  "Procedimientos Ambulatorios Proctológicos",
  "Ecografía",
  "Radiografía",
  "Tomografía Computarizada",
  "Resonancia Magnética",
  "Análisis Clínicos"
]

# Create services if they don't exist
services.each do |service_name|
  Service.find_or_create_by(name: service_name)
end

puts "#{Service.count} services available in the database"
