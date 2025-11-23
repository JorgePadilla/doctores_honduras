module ApplicationHelper
  def group_services_by_category(services)
    categories = {
      "Medicina General" => [
        "Farmacia",
        "Medicina General a recién nacido, niños, adulto y tercera edad",
        "Control de peso (Obesidad y Desnutrición)",
        "Enfermedades Pulmonares",
        "Trombosis venosa",
        "Prevención de pie Diabético",
        "Atención a mujer embarazada"
      ],
      "Especialidades Médicas" => [
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
        "Urología"
      ],
      "Gastroenterología" => [
        "Endoscopia Diagnóstica y Terapéutica",
        "Gastroenterología",
        "Enfermedades del Aparato Digestivo",
        "Cáncer de Colon",
        "Coloproctología",
        "Enfermedades y Cirugía de Colon, Recto y Ano",
        "Pólipos",
        "Enfermedades Hemorroidarias",
        "Abscesos",
        "Fístulas",
        "Fisuras",
        "Enfermedades Inflamatorias",
        "Estudios Endoscópicos Bajos",
        "Colonoscopia",
        "Polipectomía",
        "Procedimientos Ambulatorios Proctológicos"
      ],
      "Cirugía" => [
        "Cirugía General",
        "Cirugía Laparoscópica Básica",
        "Cirugía Menor dentro del Consultorio"
      ],
      "Odontología" => [
        "Extracciones / Restauraciones",
        "Limpiezas dentales"
      ],
      "Diagnóstico" => [
        "Examen de Citología",
        "Ultrasonidos",
        "Radiografías",
        "Ecografía",
        "Radiografía",
        "Tomografía Computarizada",
        "Resonancia Magnética",
        "Análisis Clínicos",
        "Laboratorio"
      ],
      "Terapias y Rehabilitación" => [
        "Lesiones que afectan los músculos, huesos y articulaciones",
        "Tratamiento Faciales y Corporales",
        "Fracturas en Huesos",
        "Evaluaciones psicológicas",
        "Estimulación temprana",
        "Terapia Física y Rehabilitación"
      ]
    }

    grouped = {}

    services.each do |service|
      category_found = false
      categories.each do |category_name, service_names|
        if service_names.include?(service.name)
          grouped[category_name] ||= []
          grouped[category_name] << service
          category_found = true
          break
        end
      end

      # If service doesn't fit in any category, put it in "Otros"
      unless category_found
        grouped["Otros"] ||= []
        grouped["Otros"] << service
      end
    end

    grouped
  end
end
