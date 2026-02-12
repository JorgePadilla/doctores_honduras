class SeedSpecialtiesSubspecialtiesAndServices < ActiveRecord::Migration[8.0]
  def up
    seed_specialties
    seed_subspecialties
    seed_services
  end

  def down
    # Data-only migration, no rollback needed
  end

  private

  def seed_specialties
    specialties = [
      "Medicina General", "Pediatría", "Ginecología", "Cardiología",
      "Dermatología", "Ortopedia", "Oftalmología", "Otorrinolaringología",
      "Neurología", "Psiquiatría", "Endocrinología", "Gastroenterología",
      "Urología", "Oncología", "Medicina Interna", "Cirugía General",
      "Anestesiología", "Radiología", "Medicina Familiar", "Nutrición",
      "Odontología", "Neumología", "Cirugía Plástica", "Fisioterapia",
      "Psicología Clínica",
      # Additional specialties from original seeds
      "Nefrología", "Reumatología", "Alergología",
      "Medicina del Deporte", "Medicina del Trabajo", "Medicina Estética",
      "Ortodoncia", "Periodoncia", "Cirugía Maxilofacial"
    ]

    specialties.each do |name|
      Specialty.find_or_create_by!(name: name)
    end
  end

  def seed_subspecialties
    data = {
      "Cardiología" => [
        "Cardiología Intervencionista", "Electrofisiología",
        "Cardiología Pediátrica", "Insuficiencia Cardíaca",
        "Cardiología No Invasiva"
      ],
      "Pediatría" => [
        "Neonatología", "Neurología Pediátrica", "Cardiología Pediátrica",
        "Gastroenterología Pediátrica", "Nefrología Pediátrica",
        "Oncología Pediátrica"
      ],
      "Ginecología" => [
        "Ginecología Oncológica", "Endocrinología Ginecológica",
        "Uroginecología", "Medicina Materno-Fetal", "Reproducción Humana"
      ],
      "Neurología" => [
        "Neurofisiología Clínica", "Neurología Vascular", "Epileptología",
        "Neurooncología", "Neurología del Dolor"
      ],
      "Ortopedia" => [
        "Cirugía de Mano", "Cirugía de Columna", "Artroscopia",
        "Traumatología Deportiva", "Cirugía de Cadera y Rodilla"
      ],
      "Oftalmología" => [
        "Retina", "Córnea", "Glaucoma",
        "Oftalmología Pediátrica", "Cirugía Plástica Ocular"
      ],
      "Gastroenterología" => [
        "Hepatología", "Endoscopia Digestiva",
        "Motilidad Digestiva", "Gastroenterología Oncológica"
      ],
      "Oncología" => [
        "Oncología Médica", "Oncología Radioterápica",
        "Hematología", "Oncología Pediátrica"
      ],
      "Psiquiatría" => [
        "Psiquiatría Infantil y Adolescente", "Psiquiatría Geriátrica",
        "Psiquiatría de Enlace", "Adicciones"
      ],
      "Dermatología" => [
        "Dermatología Oncológica", "Dermatología Pediátrica",
        "Dermatopatología", "Dermatología Estética"
      ],
      "Urología" => [
        "Urología Oncológica", "Urología Pediátrica",
        "Andrología", "Urología Funcional"
      ],
      "Cirugía General" => [
        "Cirugía Oncológica", "Cirugía Laparoscópica",
        "Cirugía de Tórax", "Cirugía Vascular"
      ]
    }

    data.each do |specialty_name, subspecialty_names|
      specialty = Specialty.find_by(name: specialty_name)
      next unless specialty

      subspecialty_names.each do |name|
        Subspecialty.find_or_create_by!(name: name, specialty: specialty)
      end
    end
  end

  def seed_services
    # General services (no specialty)
    general = [
      "Consulta General", "Consulta de Seguimiento", "Segunda Opinión Médica",
      "Chequeo Médico Preventivo", "Certificado Médico",
      "Interpretación de Exámenes", "Telemedicina / Consulta Virtual",
      "Atención a Domicilio", "Urgencias Médicas", "Referencias y Derivaciones"
    ]

    general.each { |name| Service.find_or_create_by!(name: name) }

    # Services per specialty
    per_specialty = {
      "Medicina General" => [
        "Control de Presión Arterial", "Control de Diabetes",
        "Examen Físico Completo", "Vacunación",
        "Manejo de Enfermedades Crónicas", "Curación de Heridas",
        "Retiro de Puntos", "Inyecciones", "Nebulizaciones"
      ],
      "Cardiología" => [
        "Electrocardiograma", "Ecocardiograma", "Prueba de Esfuerzo",
        "Holter de 24 Horas", "Monitoreo Ambulatorio de Presión Arterial (MAPA)",
        "Cateterismo Cardíaco", "Manejo de Insuficiencia Cardíaca",
        "Manejo de Arritmias", "Control de Hipertensión",
        "Evaluación de Riesgo Cardiovascular"
      ],
      "Dermatología" => [
        "Dermatoscopia", "Crioterapia", "Biopsia de Piel",
        "Tratamiento de Acné", "Tratamiento de Psoriasis",
        "Eliminación de Verrugas", "Tratamiento de Dermatitis",
        "Evaluación de Lunares", "Micología (Hongos)", "Dermatología Estética"
      ],
      "Endocrinología" => [
        "Manejo de Diabetes Tipo 1 y 2", "Manejo de Tiroides",
        "Evaluación de Obesidad", "Manejo de Osteoporosis",
        "Trastornos Hormonales", "Control Metabólico",
        "Manejo de Suprarrenales", "Evaluación de Crecimiento"
      ],
      "Gastroenterología" => [
        "Endoscopia Diagnóstica y Terapéutica", "Colonoscopia", "Polipectomía",
        "Manejo de Reflujo Gastroesofágico", "Manejo de Gastritis y Úlceras",
        "Manejo de Colon Irritable", "Detección de Cáncer de Colon",
        "Manejo de Enfermedad Hepática",
        "Manejo de Enfermedades Inflamatorias Intestinales",
        "Estudios Endoscópicos Bajos"
      ],
      "Ginecología" => [
        "Control Prenatal", "Papanicolaou", "Colposcopía",
        "Ultrasonido Obstétrico", "Planificación Familiar",
        "Manejo de Menopausia", "Cirugía Ginecológica",
        "Control de Embarazo de Alto Riesgo", "Atención de Parto",
        "Manejo de Infertilidad", "Ultrasonido Pélvico"
      ],
      "Neurología" => [
        "Electroencefalograma (EEG)", "Electromiografía",
        "Manejo de Epilepsia", "Manejo de Migraña y Cefaleas",
        "Evaluación de Trastornos del Sueño", "Manejo de Parkinson",
        "Evaluación de Neuropatías", "Manejo de Esclerosis Múltiple",
        "Evaluación Neurocognitiva"
      ],
      "Oftalmología" => [
        "Examen de Agudeza Visual", "Fondo de Ojo",
        "Tonometría (Glaucoma)", "Cirugía de Cataratas",
        "Cirugía Refractiva (LASIK)", "Manejo de Glaucoma",
        "Manejo de Retinopatía Diabética", "Adaptación de Lentes de Contacto",
        "Tratamiento de Ojo Seco", "Evaluación Pediátrica Oftalmológica"
      ],
      "Oncología" => [
        "Evaluación Oncológica", "Quimioterapia", "Biopsia y Diagnóstico",
        "Seguimiento Oncológico", "Manejo del Dolor Oncológico",
        "Evaluación de Tumores"
      ],
      "Ortopedia" => [
        "Infiltraciones Articulares", "Inmovilización y Férulas",
        "Cirugía de Rodilla", "Cirugía de Hombro", "Cirugía de Columna",
        "Manejo de Fracturas", "Artroscopia",
        "Prótesis de Cadera y Rodilla", "Rehabilitación Ortopédica",
        "Medicina Deportiva"
      ],
      "Pediatría" => [
        "Control de Niño Sano", "Vacunación Pediátrica",
        "Evaluación del Crecimiento y Desarrollo",
        "Manejo de Enfermedades Respiratorias",
        "Manejo de Alergias Pediátricas", "Neonatología",
        "Atención de Urgencias Pediátricas", "Control Nutricional Pediátrico"
      ],
      "Psiquiatría" => [
        "Evaluación Psiquiátrica", "Psicoterapia", "Manejo de Depresión",
        "Manejo de Ansiedad", "Manejo de Trastorno Bipolar",
        "Manejo de TDAH", "Psiquiatría Infantil y Adolescente",
        "Manejo de Adicciones"
      ],
      "Urología" => [
        "Evaluación Prostática", "Cistoscopia",
        "Litotricia (Cálculos Renales)", "Cirugía Urológica",
        "Manejo de Infecciones Urinarias", "Manejo de Incontinencia",
        "Evaluación de Fertilidad Masculina", "Circuncisión"
      ],
      "Cirugía General" => [
        "Cirugía Laparoscópica", "Cirugía de Hernias", "Apendicectomía",
        "Colecistectomía (Vesícula)", "Cirugía de Tiroides",
        "Cirugía Menor Ambulatoria", "Biopsias Quirúrgicas",
        "Drenaje de Abscesos"
      ],
      "Medicina Interna" => [
        "Manejo de Enfermedades Crónicas", "Evaluación Diagnóstica Integral",
        "Manejo de Hipertensión", "Manejo de Diabetes",
        "Manejo de Enfermedades Autoinmunes", "Evaluación Preoperatoria",
        "Manejo de Infecciones Complejas"
      ],
      "Medicina Familiar" => [
        "Atención Integral Familiar", "Control de Crecimiento Infantil",
        "Atención del Adulto Mayor", "Consejería Familiar",
        "Manejo de Enfermedades Crónicas Familiares"
      ],
      "Neumología" => [
        "Espirometría", "Manejo de Asma", "Manejo de EPOC",
        "Evaluación de Apnea del Sueño", "Broncoscopia",
        "Manejo de Neumonía", "Pruebas de Función Pulmonar"
      ],
      "Otorrinolaringología" => [
        "Audiometría", "Endoscopia Nasal", "Manejo de Sinusitis",
        "Cirugía de Amígdalas y Adenoides", "Manejo de Vértigo",
        "Manejo de Ronquido y Apnea", "Cirugía de Oído",
        "Manejo de Alergias Nasales"
      ],
      "Cirugía Plástica" => [
        "Rinoplastia", "Abdominoplastia", "Liposucción",
        "Aumento y Reducción Mamaria", "Blefaroplastia (Párpados)",
        "Cirugía Reconstructiva", "Tratamiento de Quemaduras",
        "Botox y Rellenos Faciales"
      ],
      "Anestesiología" => [
        "Anestesia General", "Anestesia Regional", "Anestesia Epidural",
        "Manejo del Dolor Crónico", "Bloqueos Nerviosos", "Sedación Consciente"
      ],
      "Fisioterapia" => [
        "Rehabilitación Física", "Terapia Manual", "Electroterapia",
        "Hidroterapia", "Rehabilitación Post-Quirúrgica",
        "Terapia Respiratoria", "Rehabilitación Neurológica",
        "Terapia Deportiva"
      ],
      "Nutrición" => [
        "Evaluación Nutricional", "Plan de Alimentación Personalizado",
        "Manejo de Obesidad y Sobrepeso", "Nutrición Deportiva",
        "Nutrición Pediátrica", "Manejo Nutricional de Diabetes",
        "Nutrición en Embarazo y Lactancia"
      ],
      "Psicología Clínica" => [
        "Terapia Individual", "Terapia de Pareja", "Terapia Familiar",
        "Terapia Cognitivo-Conductual", "Evaluación Psicológica",
        "Manejo de Estrés y Ansiedad", "Orientación Vocacional"
      ],
      "Odontología" => [
        "Limpieza Dental", "Extracciones",
        "Endodoncia (Tratamiento de Conductos)", "Ortodoncia",
        "Implantes Dentales", "Blanqueamiento Dental",
        "Prótesis Dentales", "Cirugía Oral", "Periodoncia"
      ],
      "Radiología" => [
        "Radiografía Digital", "Tomografía Computarizada (TAC)",
        "Resonancia Magnética (RM)", "Ecografía / Ultrasonido",
        "Mamografía", "Densitometría Ósea", "Radiología Intervencionista"
      ]
    }

    per_specialty.each do |specialty_name, service_names|
      specialty = Specialty.find_by(name: specialty_name)
      service_names.each do |name|
        service = Service.find_or_initialize_by(name: name)
        service.specialty = specialty if specialty && service.specialty_id.nil?
        service.save!
      end
    end
  end
end
