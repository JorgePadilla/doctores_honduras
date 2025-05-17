# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create suppliers
puts "Creating suppliers..."

# Skip if suppliers already exist
if Supplier.count == 0
  suppliers = [
    {
      name: "Mey-Ko",
      address: "Col. Ruben Dario, Calle 8, #257",
      phone: "2234-3504",
      email: "info@meyko.hn",
      description: "Equipos médicos y suministros para el cuidado de la salud",
      logo_url: "https://images.unsplash.com/photo-1516876437184-593fda40c7ce?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fG1lZGljYWwlMjBzdXBwbGllc3xlbnwwfHwwfHx8MA%3D%3D"
    },
    {
      name: "Medihospital",
      address: "Blvd. Suyapa, Tegucigalpa",
      phone: "2239-7800",
      email: "ventas@medihospital.hn",
      description: "Distribuidores de equipos médicos y material quirúrgico",
      logo_url: "https://images.unsplash.com/photo-1587351021759-3e566b3db4f1?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fG1lZGljYWwlMjBzdXBwbGllc3xlbnwwfHwwfHx8MA%3D%3D"
    },
    {
      name: "Dimex Medical",
      address: "Col. Palmira, Ave. República de Panamá",
      phone: "2216-5950",
      email: "contacto@dimexmedical.hn",
      description: "Equipos y suministros médicos de alta calidad",
      logo_url: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWVkaWNhbCUyMGVxdWlwbWVudHxlbnwwfHwwfHx8MA%3D%3D"
    },
    {
      name: "Droguería Nacional",
      address: "Col. Las Colinas, Blvd. Francia",
      phone: "2221-3090",
      email: "info@dronacional.hn",
      description: "Distribución de medicamentos y equipos médicos",
      logo_url: "https://images.unsplash.com/photo-1563453392212-326f5e854473?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fHBoYXJtYWN5fGVufDB8fDB8fHww"
    },
    {
      name: "Farinter",
      address: "Col. Payaquí, Tegucigalpa",
      phone: "2280-0000",
      email: "servicioalcliente@farinter.hn",
      description: "Productos farmacéuticos y equipos médicos",
      logo_url: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGhhcm1hY3l8ZW58MHx8MHx8fDA%3D"
    }
  ]

  created_suppliers = Supplier.create!(suppliers)
  puts "Created #{created_suppliers.size} suppliers"

  # Create product categories
  categories = [
    "Cuidado del Diabético",
    "Cuidado en Casa",
    "Equipo Diagnóstico",
    "Rehabilitación",
    "Fisioterapia",
    "Movilidad",
    "Terapia para Varices",
    "Terapia Respiratoria"
  ]

  # Create products for each supplier
  puts "Creating products..."
  
  created_suppliers.each do |supplier|
    # Create 15-20 products for each supplier to demonstrate pagination
    product_count = rand(15..20)
    
    product_count.times do |i|
      category = categories.sample
      sku = "#{supplier.name[0..2].upcase}-#{category[0..2].upcase}-#{100 + i}"
      
      product_name = case category
      when "Cuidado del Diabético"
        ["Glucómetro Kit", "Cintas desechables", "Lancetas", "Estuche de viaje para insulina", "Medidor de presión"].sample
      when "Cuidado en Casa"
        ["Almohada refrescante", "Toallitas con alcohol", "Termómetro digital", "Tensiómetro automático", "Nebulizador portátil"].sample
      when "Equipo Diagnóstico"
        ["Estetoscopio", "Oxímetro de pulso", "Otoscopio", "Báscula digital", "Termómetro infrarrojo"].sample
      when "Rehabilitación"
        ["Banda elástica", "Balón terapéutico", "Pesas para tobillos", "Colchoneta de ejercicio", "Rueda para abdominales"].sample
      when "Fisioterapia"
        ["TENS portátil", "Compresas frío/calor", "Masajeador eléctrico", "Ultrasonido terapéutico", "Lámpara infrarroja"].sample
      when "Movilidad"
        ["Bastón ajustable", "Andador plegable", "Silla de ruedas", "Muletas axilares", "Scooter eléctrico"].sample
      when "Terapia para Varices"
        ["Medias de compresión", "Bomba de compresión secuencial", "Vendas elásticas", "Almohada elevadora", "Crema para varices"].sample
      when "Terapia Respiratoria"
        ["Inhalador", "Oxímetro", "Aspirador de secreciones", "Concentrador de oxígeno", "Máscara de nebulización"].sample
      end
      
      # Add a suffix to make each product name unique
      product_name = "#{product_name} - #{supplier.name} #{i+1}"
      
      description = "Dispositivo médico de alta calidad para #{category.downcase}. Ideal para uso profesional o doméstico. Fabricado con los más altos estándares de calidad y seguridad."
      
      supplier.products.create!(
        name: product_name,
        sku: sku,
        description: description,
        price: rand(10.0..500.0).round(2),
        category: category,
        image_url: "https://source.unsplash.com/random/300x200/?medical,#{category.downcase.gsub(' ', '-')}"
      )
    end
  end
  
  total_products = Product.count
  puts "Created #{total_products} products"
else
  puts "Suppliers already exist, skipping seed"
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating sample data for doctor profiles..."

# Skip if we already have doctors
if DoctorProfile.count >= 5
  puts "#{DoctorProfile.count} doctor profiles already exist. Skipping seed data creation."
  exit
end

# Generate a timestamp to make emails unique
timestamp = Time.now.to_i

# Create sample users for doctors
puts "Creating sample users and doctor profiles..."

# Sample specializations
specializations = [
  "Cardiología",
  "Dermatología",
  "Endocrinología",
  "Gastroenterología",
  "Ginecología",
  "Neurología",
  "Oftalmología",
  "Oncología",
  "Ortopedia",
  "Pediatría",
  "Psiquiatría",
  "Urología",
  "Medicina Interna",
  "Cirugía General",
  "Medicina Familiar",
  "Otorrinolaringología",
  "Neumología",
  "Radiología",
  "Anestesiología",
  "Manejo del Dolor",
  "Psicología Clínica"
]

# Sample locations
locations = [
  "Tegucigalpa, MDC",
  "San Pedro Sula, Cortés",
  "La Ceiba, Atlántida",
  "Tela, Atlántida",
  "Choluteca, Choluteca",
  "Comayagua, Comayagua",
  "Siguatepeque, Comayagua",
  "Juticalpa, Olancho",
  "Santa Rosa de Copán, Copán",
  "Puerto Cortés, Cortés"
]

# Create 20 doctors
doctors = []

# First two doctors from the original seed
user1 = User.create!(
  email: "luis.martinez.#{timestamp}@example.com",
  password: "password123",
  password_confirmation: "password123"
)

doctors << DoctorProfile.create!(
  user: user1,
  name: "Dr. Luis Martínez Arita",
  specialization: "Manejo del Dolor",
  description: "Especialista en manejo del dolor con más de 10 años de experiencia.",
  location: "Tela, Atlántida",
  medical_license: "Medicina General",
  image_url: "https://randomuser.me/api/portraits/men/75.jpg"
)

user2 = User.create!(
  email: "ana.alvarez.#{timestamp}@example.com",
  password: "password123",
  password_confirmation: "password123"
)

doctors << DoctorProfile.create!(
  user: user2,
  name: "Licda. Ana Ruth Álvarez",
  specialization: "Psicología Clínica, Infanto-Juvenil y Terapia Familiar",
  description: "Especialista en psicología clínica con enfoque en terapia familiar e infanto-juvenil.",
  location: "Tegucigalpa, MDC",
  medical_license: "Psicología",
  image_url: "https://randomuser.me/api/portraits/women/65.jpg"
)

# Create 18 more doctors
18.times do |i|
  # Alternate between male and female doctors
  gender = i.even? ? "men" : "women"
  # Use a different image for each doctor
  image_number = i + 10
  
  user = User.create!(
    email: "doctor#{i+3}.#{timestamp}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
  
  # Generate a random name
  first_names_male = ["Carlos", "Juan", "Miguel", "José", "Antonio", "Francisco", "Roberto", "David", "Fernando", "Rafael"]
  first_names_female = ["María", "Ana", "Laura", "Sofía", "Carmen", "Isabel", "Patricia", "Gabriela", "Rosa", "Claudia"]
  last_names = ["García", "Martínez", "López", "Hernández", "Pérez", "González", "Rodríguez", "Sánchez", "Ramírez", "Torres", "Flores", "Rivera", "Morales", "Reyes", "Cruz"]
  
  first_name = gender == "men" ? first_names_male.sample : first_names_female.sample
  last_name = "#{last_names.sample} #{last_names.sample}"
  title = gender == "men" ? "Dr." : ["Dra.", "Licda."].sample
  
  # Select a random specialization
  spec = specializations.sample
  
  # Create the doctor profile
  doctors << DoctorProfile.create!(
    user: user,
    name: "#{title} #{first_name} #{last_name}",
    specialization: spec,
    description: "Especialista en #{spec} con experiencia en atención de pacientes de todas las edades.",
    location: locations.sample,
    medical_license: spec,
    image_url: "https://randomuser.me/api/portraits/#{gender}/#{image_number}.jpg"
  )
end

# Create sample establishments
puts "Creating sample establishments..."

# Sample establishment names and types
establishment_data = [
  { name: "Policlínica del Atlántico", type: "Clínica" },
  { name: "Clínicas Millenium", type: "Clínica" },
  { name: "Hospital Escuela", type: "Hospital" },
  { name: "Hospital San Felipe", type: "Hospital" },
  { name: "Hospital Militar", type: "Hospital" },
  { name: "Hospital Viera", type: "Hospital" },
  { name: "Centro Médico Hondureño", type: "Centro Médico" },
  { name: "Centro Especializado San Jorge", type: "Centro Médico" },
  { name: "Clínica Médica Cristiana", type: "Clínica" },
  { name: "Clínica La Salud", type: "Clínica" },
  { name: "Centro Médico La Paz", type: "Centro Médico" },
  { name: "Hospital D'Antoni", type: "Hospital" },
  { name: "Clínica Santa María", type: "Clínica" },
  { name: "Centro Médico Comayagua", type: "Centro Médico" },
  { name: "Hospital Regional del Norte", type: "Hospital" }
]

# Sample addresses by city
address_templates = {
  "Tegucigalpa, MDC" => [
    "Col. Tepeyac, %s piso, clínica %s, Calle Olancho",
    "Col. Palmira, Calle Principal, Edificio %s",
    "Col. Kennedy, Blvd. Centroamérica, frente a %s",
    "Col. Miraflores, Calle %s, Casa #%s",
    "Blvd. Morazán, Torre %s, %s piso"
  ],
  "San Pedro Sula, Cortés" => [
    "Barrio Río de Piedras, %s Avenida, %s Calle",
    "Col. Villas del Sol, Blvd. del Sur, Edificio %s",
    "Barrio Guamilito, Calle %s, Edificio %s",
    "Col. Universidad, frente a %s",
    "Barrio El Centro, %s Avenida, %s Calle"
  ],
  "La Ceiba, Atlántida" => [
    "Barrio La Isla, %s Calle, %s Avenida",
    "Barrio El Centro, frente a %s",
    "Col. El Naranjal, Calle Principal, Casa #%s",
    "Barrio Mejía, cerca de %s",
    "Zona Viva, Edificio %s, Local %s"
  ],
  "Tela, Atlántida" => [
    "Barrio el Centro, frente a Gasolinera UNO",
    "Barrio Venecia, %s Calle",
    "Zona Turística, cerca de %s",
    "Barrio Independencia, Casa #%s",
    "Calle Principal, Edificio %s, Local %s"
  ]
}

# Create establishments
establishments = []

# Hospital and clinic logo images from Unsplash
establishment_logos = [
  "https://images.unsplash.com/photo-1587351021759-3e566b3db4f1?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1504439468489-c8920d796a29?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1516549655669-df668a1d9930?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1587746746177-a8de4a8f3648?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1629909615184-74f495363b67?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1516549655669-df668a1d9930?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3"
]

# Hospital and clinic building images from Unsplash
building_images = [
  "https://images.unsplash.com/photo-1629131726692-1accd0c53ce0?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1586773860397-64bfab45a1f9?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1512678080530-7760d81faba6?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1605146769289-440113cc3d00?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
  "https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3"
]

# First two specific establishments from original seed
establishments << Establishment.create!(
  name: "Policlínica del Atlántico",
  est_type: "Clínica",
  address: "Barrio el Centro de Tela, frente a Gasolinera UNO",
  phone: "(504) 2448-2109",
  map_link: "https://maps.google.com/?q=Policlínica+del+Atlántico,+Tela",
  logo_url: establishment_logos[0],
  building_image_url: building_images[0]
)

establishments << Establishment.create!(
  name: "Clínicas Millenium",
  est_type: "Clínica",
  address: "Col. Tepeyac, 7mo. piso, clínica 705, Calle Olancho, Tegucigalpa MDC",
  phone: "(504) 2232-0718",
  map_link: "https://maps.google.com/?q=Clínicas+Millenium,+Tegucigalpa",
  logo_url: establishment_logos[1],
  building_image_url: building_images[1]
)

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

specialties.each do |name|
  Specialty.find_or_create_by!(name: name)
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

services.each do |name|
  Service.find_or_create_by!(name: name)
end

puts "Created #{Service.count} services"

# Create more establishments
13.times do |i|
  # Select a random establishment data
  est_data = establishment_data[i + 2]
  
  # Select a random location from our defined locations that have address templates
  location = address_templates.keys.sample
  city = location.split(",").first
  
  # Generate a random address based on the city
  address_template = address_templates[location].sample
  landmarks = ["Banco Atlantida", "Supermercado La Colonia", "Parque Central", "Plaza Miraflores", "Mall Multiplaza", "Universidad Nacional", "Estadio Nacional", "Hotel Marriott", "Catedral", "Mercado", "Gasolinera Uno", "Hospital", "Farmacia Siman", "Escuela Americana", "Centro Comercial"]
  
  # Format the address with random numbers and landmarks
  address = format(address_template, 
    ["1er", "2do", "3er", "4to", "5to", "6to", "7mo", "8vo", "9no", "10mo"].sample,
    rand(100..999).to_s,
    landmarks.sample,
    ["A", "B", "C", "D", "E", "F", "G", "H"].sample,
    rand(1..20).to_s)
  
  # Generate a random phone number
  phone = "(504) #{rand(2200..9999)}-#{rand(1000..9999)}"
  
  # Create the establishment
  establishments << Establishment.create!(
    name: est_data[:name],
    est_type: est_data[:type],
    address: "#{address}, #{location}",
    phone: phone,
    map_link: "https://maps.google.com/?q=#{est_data[:name].gsub(' ', '+')},+#{city.gsub(' ', '+')}",
    logo_url: establishment_logos[i + 2], # Use the corresponding logo from our array
    building_image_url: building_images[i + 2] # Use the corresponding building image from our array
  )
end

# Associate specialties and services with establishments
puts "Associating specialties and services with establishments..."

# Get all specialties and services
all_specialties = Specialty.all
all_services = Service.all

# Associate specialties and services with the first establishment (Policlínica del Atlántico)
centro_medico_specialties = ["Ortodoncia", "Nutrición", "Pediatría", "Psicología-Podiatría", "Medicina Estética", "Laparoscopía", "Ortopedia y Traumatología"]
centro_medico_services = ["Farmacia", "Medicina General a recién nacido, niños, adulto y tercera edad", "Extracciones / Restauraciones", "Examen de Citología", "Lesiones que afectan los músculos, huesos y articulaciones", "Ultrasonidos", "Tratamiento Faciales y Corporales", "Trombosis venosa", "Prevención de pie Diabético", "Atención a mujer embarazada", "Radiografías", "Limpiezas dentales", "Control de peso (Obesidad y Desnutrición)", "Enfermedades Pulmonares", "Fracturas en Huesos", "Evaluaciones psicológicas", "Estimulación temprana", "Laboratorio", "Terapia Física y Rehabilitación"]

centro_medico_specialties.each do |specialty_name|
  specialty = Specialty.find_by(name: specialty_name)
  if specialty
    EstablishmentSpecialty.find_or_create_by!(establishment: establishments[0], specialty: specialty)
  end
end

centro_medico_services.each do |service_name|
  service = Service.find_by(name: service_name)
  if service
    EstablishmentService.find_or_create_by!(establishment: establishments[0], service: service)
  end
end

# For other establishments, assign random specialties and services
establishments[1..].each do |establishment|
  # Assign 3-7 random specialties
  num_specialties = rand(3..7)
  establishment_specialties = all_specialties.sample(num_specialties)
  
  establishment_specialties.each do |specialty|
    EstablishmentSpecialty.find_or_create_by!(establishment: establishment, specialty: specialty)
  end
  
  # Assign 5-10 random services
  num_services = rand(5..10)
  establishment_services = all_services.sample(num_services)
  
  establishment_services.each do |service|
    EstablishmentService.find_or_create_by!(establishment: establishment, service: service)
  end
end

puts "Specialties and services associated with establishments"

# Associate doctors with establishments
puts "Associating doctors with establishments..."

# Associate first two doctors with specific establishments
DoctorEstablishment.create!(doctor_profile: doctors[0], establishment: establishments[0])
DoctorEstablishment.create!(doctor_profile: doctors[1], establishment: establishments[1])

# Associate the rest of the doctors with random establishments
# Each doctor will have 1-3 establishments
doctors[2..].each do |doctor|
  # Determine how many establishments this doctor will have (1-3)
  num_establishments = rand(1..3)
  
  # Select random establishments for this doctor
  doctor_establishments = establishments.sample(num_establishments)
  
  # Create the associations
  doctor_establishments.each do |establishment|
    DoctorEstablishment.create!(doctor_profile: doctor, establishment: establishment)
  end
end

puts "Seed data created successfully!"
