# Base dictionary for the doctor search (Ticket A2). Maps lay terms patients type
# to clinical keywords that match service/specialty names. Idempotent; the admin
# curates/expands this from Admin -> Sinónimos. The definitive list is a clinical
# decision of the medical partner — this is only a starter set.
puts "Seeding search synonyms..."

SYNONYMS = {
  "caries"                => "Endodoncia, Limpieza Dental, Extracciones, Odontología",
  "muela"                 => "Extracciones, Endodoncia, Odontología",
  "dolor de muela"        => "Extracciones, Endodoncia, Odontología",
  "dientes"               => "Odontología, Limpieza Dental, Ortodoncia",
  "frenos"                => "Ortodoncia, Odontología",
  "apendicitis"           => "Apendicectomía, Cirugía General",
  "apéndice"              => "Apendicectomía, Cirugía General",
  "vesícula"              => "Colecistectomía, Cirugía General",
  "hernia"                => "Cirugía General, Herniorrafia",
  "cesárea"               => "Parto, Obstetricia, Ginecología",
  "parto"                 => "Obstetricia, Ginecología",
  "embarazo"              => "Obstetricia, Ginecología, Control Prenatal",
  "piedras en el riñón"   => "Litotricia, Urología",
  "cálculos renales"      => "Litotricia, Urología",
  "próstata"              => "Urología",
  "glaucoma"              => "Tonometría, Oftalmología",
  "vista"                 => "Oftalmología, Optometría",
  "ojos"                  => "Oftalmología",
  "diabetes"              => "Manejo de Diabetes, Endocrinología",
  "azúcar"                => "Manejo de Diabetes, Endocrinología",
  "presión alta"          => "Manejo de Hipertensión, Cardiología",
  "hipertensión"          => "Manejo de Hipertensión, Cardiología",
  "corazón"               => "Cardiología, Electrocardiograma",
  "várices"               => "Cirugía Vascular, Escleroterapia",
  "piel"                  => "Dermatología",
  "acné"                  => "Dermatología",
  "huesos"                => "Ortopedia, Traumatología",
  "fractura"              => "Ortopedia, Traumatología",
  "niños"                 => "Pediatría",
  "cabeza"                => "Neurología",
  "migraña"               => "Neurología",
  "tiroides"              => "Endocrinología"
}.freeze

SYNONYMS.each do |term, keywords|
  SearchSynonym.find_or_initialize_by(term: SearchSynonym.normalize(term)).update!(keywords: keywords)
end

puts "Search synonyms ready (#{SearchSynonym.count} términos)"
