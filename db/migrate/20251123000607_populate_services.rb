class PopulateServices < ActiveRecord::Migration[8.0]
  def up
    # Services from main seeds.rb
    services_from_main_seeds = [
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

    # Services from services.rb seed file
    services_from_services_seed = [
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

    # Combine all services
    all_services = services_from_main_seeds + services_from_services_seed

    # Insert services that don't exist yet
    all_services.each do |service_name|
      Service.find_or_create_by(name: service_name)
    end
  end

  def down
    # This migration only adds data, so rolling back doesn't remove existing services
    # to avoid data loss in case services were added manually
  end
end
