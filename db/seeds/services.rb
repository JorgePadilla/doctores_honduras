# Medical services/tags for doctors in Honduras
# Services can be general (no specialty) or linked to a specific specialty

puts "Seeding services..."

# Helper to create services for a specialty
def seed_services(specialty_name, service_names)
  specialty = Specialty.find_by(name: specialty_name)
  service_names.each do |name|
    service = Service.find_or_initialize_by(name: name)
    service.specialty = specialty if specialty && service.specialty_id.nil?
    service.save!
  end
end

# General services (available to all specialties)
general_services = [
  "Consulta General",
  "Consulta de Seguimiento",
  "Segunda Opinión Médica",
  "Chequeo Médico Preventivo",
  "Certificado Médico",
  "Interpretación de Exámenes",
  "Telemedicina / Consulta Virtual",
  "Atención a Domicilio",
  "Urgencias Médicas",
  "Referencias y Derivaciones",
]

general_services.each do |name|
  Service.find_or_create_by!(name: name)
end

# Medicina General
seed_services("Medicina General", [
  "Control de Presión Arterial",
  "Control de Diabetes",
  "Examen Físico Completo",
  "Vacunación",
  "Manejo de Enfermedades Crónicas",
  "Curación de Heridas",
  "Retiro de Puntos",
  "Inyecciones",
  "Nebulizaciones",
])

# Cardiología
seed_services("Cardiología", [
  "Electrocardiograma",
  "Ecocardiograma",
  "Prueba de Esfuerzo",
  "Holter de 24 Horas",
  "Monitoreo Ambulatorio de Presión Arterial (MAPA)",
  "Cateterismo Cardíaco",
  "Manejo de Insuficiencia Cardíaca",
  "Manejo de Arritmias",
  "Control de Hipertensión",
  "Evaluación de Riesgo Cardiovascular",
])

# Dermatología
seed_services("Dermatología", [
  "Dermatoscopia",
  "Crioterapia",
  "Biopsia de Piel",
  "Tratamiento de Acné",
  "Tratamiento de Psoriasis",
  "Eliminación de Verrugas",
  "Tratamiento de Dermatitis",
  "Evaluación de Lunares",
  "Micología (Hongos)",
  "Dermatología Estética",
])

# Endocrinología
seed_services("Endocrinología", [
  "Manejo de Diabetes Tipo 1 y 2",
  "Manejo de Tiroides",
  "Evaluación de Obesidad",
  "Manejo de Osteoporosis",
  "Trastornos Hormonales",
  "Control Metabólico",
  "Manejo de Suprarrenales",
  "Evaluación de Crecimiento",
])

# Gastroenterología
seed_services("Gastroenterología", [
  "Endoscopia Diagnóstica y Terapéutica",
  "Colonoscopia",
  "Polipectomía",
  "Manejo de Reflujo Gastroesofágico",
  "Manejo de Gastritis y Úlceras",
  "Manejo de Colon Irritable",
  "Detección de Cáncer de Colon",
  "Manejo de Enfermedad Hepática",
  "Manejo de Enfermedades Inflamatorias Intestinales",
  "Estudios Endoscópicos Bajos",
])

# Ginecología
seed_services("Ginecología", [
  "Control Prenatal",
  "Papanicolaou",
  "Colposcopía",
  "Ultrasonido Obstétrico",
  "Planificación Familiar",
  "Manejo de Menopausia",
  "Cirugía Ginecológica",
  "Control de Embarazo de Alto Riesgo",
  "Atención de Parto",
  "Manejo de Infertilidad",
  "Ultrasonido Pélvico",
])

# Neurología
seed_services("Neurología", [
  "Electroencefalograma (EEG)",
  "Electromiografía",
  "Manejo de Epilepsia",
  "Manejo de Migraña y Cefaleas",
  "Evaluación de Trastornos del Sueño",
  "Manejo de Parkinson",
  "Evaluación de Neuropatías",
  "Manejo de Esclerosis Múltiple",
  "Evaluación Neurocognitiva",
])

# Oftalmología
seed_services("Oftalmología", [
  "Examen de Agudeza Visual",
  "Fondo de Ojo",
  "Tonometría (Glaucoma)",
  "Cirugía de Cataratas",
  "Cirugía Refractiva (LASIK)",
  "Manejo de Glaucoma",
  "Manejo de Retinopatía Diabética",
  "Adaptación de Lentes de Contacto",
  "Tratamiento de Ojo Seco",
  "Evaluación Pediátrica Oftalmológica",
])

# Oncología
seed_services("Oncología", [
  "Evaluación Oncológica",
  "Quimioterapia",
  "Biopsia y Diagnóstico",
  "Seguimiento Oncológico",
  "Manejo del Dolor Oncológico",
  "Evaluación de Tumores",
])

# Ortopedia
seed_services("Ortopedia", [
  "Infiltraciones Articulares",
  "Inmovilización y Férulas",
  "Cirugía de Rodilla",
  "Cirugía de Hombro",
  "Cirugía de Columna",
  "Manejo de Fracturas",
  "Artroscopia",
  "Prótesis de Cadera y Rodilla",
  "Rehabilitación Ortopédica",
  "Medicina Deportiva",
])

# Pediatría
seed_services("Pediatría", [
  "Control de Niño Sano",
  "Vacunación Pediátrica",
  "Evaluación del Crecimiento y Desarrollo",
  "Manejo de Enfermedades Respiratorias",
  "Manejo de Alergias Pediátricas",
  "Neonatología",
  "Atención de Urgencias Pediátricas",
  "Control Nutricional Pediátrico",
])

# Psiquiatría
seed_services("Psiquiatría", [
  "Evaluación Psiquiátrica",
  "Psicoterapia",
  "Manejo de Depresión",
  "Manejo de Ansiedad",
  "Manejo de Trastorno Bipolar",
  "Manejo de TDAH",
  "Psiquiatría Infantil y Adolescente",
  "Manejo de Adicciones",
])

# Urología
seed_services("Urología", [
  "Evaluación Prostática",
  "Cistoscopia",
  "Litotricia (Cálculos Renales)",
  "Cirugía Urológica",
  "Manejo de Infecciones Urinarias",
  "Manejo de Incontinencia",
  "Evaluación de Fertilidad Masculina",
  "Circuncisión",
])

# Cirugía General
seed_services("Cirugía General", [
  "Cirugía Laparoscópica",
  "Cirugía de Hernias",
  "Apendicectomía",
  "Colecistectomía (Vesícula)",
  "Cirugía de Tiroides",
  "Cirugía Menor Ambulatoria",
  "Biopsias Quirúrgicas",
  "Drenaje de Abscesos",
])

# Medicina Interna
seed_services("Medicina Interna", [
  "Manejo de Enfermedades Crónicas",
  "Evaluación Diagnóstica Integral",
  "Manejo de Hipertensión",
  "Manejo de Diabetes",
  "Manejo de Enfermedades Autoinmunes",
  "Evaluación Preoperatoria",
  "Manejo de Infecciones Complejas",
])

# Medicina Familiar
seed_services("Medicina Familiar", [
  "Atención Integral Familiar",
  "Control de Crecimiento Infantil",
  "Atención del Adulto Mayor",
  "Consejería Familiar",
  "Manejo de Enfermedades Crónicas Familiares",
])

# Neumología
seed_services("Neumología", [
  "Espirometría",
  "Manejo de Asma",
  "Manejo de EPOC",
  "Evaluación de Apnea del Sueño",
  "Broncoscopia",
  "Manejo de Neumonía",
  "Pruebas de Función Pulmonar",
])

# Otorrinolaringología
seed_services("Otorrinolaringología", [
  "Audiometría",
  "Endoscopia Nasal",
  "Manejo de Sinusitis",
  "Cirugía de Amígdalas y Adenoides",
  "Manejo de Vértigo",
  "Manejo de Ronquido y Apnea",
  "Cirugía de Oído",
  "Manejo de Alergias Nasales",
])

# Cirugía Plástica
seed_services("Cirugía Plástica", [
  "Rinoplastia",
  "Abdominoplastia",
  "Liposucción",
  "Aumento y Reducción Mamaria",
  "Blefaroplastia (Párpados)",
  "Cirugía Reconstructiva",
  "Tratamiento de Quemaduras",
  "Botox y Rellenos Faciales",
])

# Anestesiología
seed_services("Anestesiología", [
  "Anestesia General",
  "Anestesia Regional",
  "Anestesia Epidural",
  "Manejo del Dolor Crónico",
  "Bloqueos Nerviosos",
  "Sedación Consciente",
])

# Fisioterapia
seed_services("Fisioterapia", [
  "Rehabilitación Física",
  "Terapia Manual",
  "Electroterapia",
  "Hidroterapia",
  "Rehabilitación Post-Quirúrgica",
  "Terapia Respiratoria",
  "Rehabilitación Neurológica",
  "Terapia Deportiva",
])

# Nutrición
seed_services("Nutrición", [
  "Evaluación Nutricional",
  "Plan de Alimentación Personalizado",
  "Manejo de Obesidad y Sobrepeso",
  "Nutrición Deportiva",
  "Nutrición Pediátrica",
  "Manejo Nutricional de Diabetes",
  "Nutrición en Embarazo y Lactancia",
])

# Psicología Clínica
seed_services("Psicología Clínica", [
  "Terapia Individual",
  "Terapia de Pareja",
  "Terapia Familiar",
  "Terapia Cognitivo-Conductual",
  "Evaluación Psicológica",
  "Manejo de Estrés y Ansiedad",
  "Orientación Vocacional",
])

# Odontología
seed_services("Odontología", [
  "Limpieza Dental",
  "Extracciones",
  "Endodoncia (Tratamiento de Conductos)",
  "Ortodoncia",
  "Implantes Dentales",
  "Blanqueamiento Dental",
  "Prótesis Dentales",
  "Cirugía Oral",
  "Periodoncia",
])

# Radiología
seed_services("Radiología", [
  "Radiografía Digital",
  "Tomografía Computarizada (TAC)",
  "Resonancia Magnética (RM)",
  "Ecografía / Ultrasonido",
  "Mamografía",
  "Densitometría Ósea",
  "Radiología Intervencionista",
])

puts "#{Service.count} services available in the database"
