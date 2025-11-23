class AddMoreServicesAndSpecialties < ActiveRecord::Migration[8.0]
  def up
    # Additional Odontología services
    odontologia_services = [
      "Blanqueamiento dental",
      "Implantes dentales",
      "Ortodoncia",
      "Endodoncia",
      "Prótesis dentales",
      "Periodoncia",
      "Odontopediatría",
      "Cirugía oral",
      "Rehabilitación oral",
      "Estética dental",
      "Radiografía dental",
      "Tratamiento de caries",
      "Sellantes dentales",
      "Fluorización",
      "Tratamiento de encías"
    ]

    # Additional medical specialties
    additional_specialties = [
      "Alergología",
      "Anatomía Patológica",
      "Angiología",
      "Cirugía Cardiovascular",
      "Cirugía Pediátrica",
      "Cirugía Plástica",
      "Genética Médica",
      "Geriatría",
      "Hematología",
      "Infectología",
      "Medicina Crítica",
      "Medicina del Dolor",
      "Medicina Física y Rehabilitación",
      "Medicina Nuclear",
      "Neumología",
      "Patología Clínica",
      "Toxicología"
    ]

    # Additional general medical services
    general_services = [
      "Consulta de primera vez",
      "Consulta de control",
      "Atención de urgencias",
      "Hospitalización",
      "Cuidados intensivos",
      "Cuidados paliativos",
      "Medicina preventiva",
      "Vacunación",
      "Planificación familiar",
      "Control prenatal",
      "Parto natural",
      "Cesárea",
      "Lactancia materna",
      "Crecimiento y desarrollo",
      "Salud mental",
      "Nutrición clínica",
      "Fisioterapia respiratoria"
    ]

    # Additional diagnostic services
    diagnostic_services = [
      "Electrocardiograma",
      "Electroencefalograma",
      "Espirometría",
      "Holter",
      "Mamografía",
      "Densitometría ósea",
      "Endoscopia digestiva alta",
      "Colonoscopia",
      "Broncoscopia",
      "Cistoscopia",
      "Artroscopia",
      "Biopsia",
      "Citología",
      "Cultivos",
      "Pruebas de alergia",
      "Pruebas de función tiroidea"
    ]

    # Additional surgical services
    surgical_services = [
      "Cirugía ambulatoria",
      "Cirugía de emergencia",
      "Cirugía programada",
      "Anestesia general",
      "Anestesia regional",
      "Sedación consciente",
      "Cuidados postoperatorios",
      "Drenajes quirúrgicos",
      "Suturas",
      "Curaciones",
      "Retiro de puntos",
      "Inmovilizaciones",
      "Yesos",
      "Férulas",
      "Vendajes"
    ]

    # Create all services
    all_services = odontologia_services + general_services + diagnostic_services + surgical_services

    all_services.each do |service_name|
      Service.find_or_create_by!(name: service_name)
    end

    # Create additional specialties
    additional_specialties.each do |specialty_name|
      Specialty.find_or_create_by!(name: specialty_name)
    end
  end

  def down
    # Remove the services we added (optional - for rollback)
    services_to_remove = [
      "Blanqueamiento dental",
      "Implantes dentales",
      "Ortodoncia",
      "Endodoncia",
      "Prótesis dentales",
      "Periodoncia",
      "Odontopediatría",
      "Cirugía oral",
      "Rehabilitación oral",
      "Estética dental",
      "Radiografía dental",
      "Tratamiento de caries",
      "Sellantes dentales",
      "Fluorización",
      "Tratamiento de encías",
      "Consulta de primera vez",
      "Consulta de control",
      "Atención de urgencias",
      "Hospitalización",
      "Cuidados intensivos",
      "Cuidados paliativos",
      "Medicina preventiva",
      "Vacunación",
      "Planificación familiar",
      "Control prenatal",
      "Parto natural",
      "Cesárea",
      "Lactancia materna",
      "Crecimiento y desarrollo",
      "Salud mental",
      "Nutrición clínica",
      "Fisioterapia respiratoria",
      "Electrocardiograma",
      "Electroencefalograma",
      "Espirometría",
      "Holter",
      "Mamografía",
      "Densitometría ósea",
      "Endoscopia digestiva alta",
      "Colonoscopia",
      "Broncoscopia",
      "Cistoscopia",
      "Artroscopia",
      "Biopsia",
      "Citología",
      "Cultivos",
      "Pruebas de alergia",
      "Pruebas de función tiroidea",
      "Cirugía ambulatoria",
      "Cirugía de emergencia",
      "Cirugía programada",
      "Anestesia general",
      "Anestesia regional",
      "Sedación consciente",
      "Cuidados postoperatorios",
      "Drenajes quirúrgicos",
      "Suturas",
      "Curaciones",
      "Retiro de puntos",
      "Inmovilizaciones",
      "Yesos",
      "Férulas",
      "Vendajes"
    ]

    services_to_remove.each do |service_name|
      Service.find_by(name: service_name)&.destroy
    end

    # Remove additional specialties
    specialties_to_remove = [
      "Alergología",
      "Anatomía Patológica",
      "Angiología",
      "Cirugía Cardiovascular",
      "Cirugía Pediátrica",
      "Cirugía Plástica",
      "Genética Médica",
      "Geriatría",
      "Hematología",
      "Infectología",
      "Medicina Crítica",
      "Medicina del Dolor",
      "Medicina Física y Rehabilitación",
      "Medicina Nuclear",
      "Neumología",
      "Patología Clínica",
      "Toxicología"
    ]

    specialties_to_remove.each do |specialty_name|
      Specialty.find_by(name: specialty_name)&.destroy
    end
  end
end
