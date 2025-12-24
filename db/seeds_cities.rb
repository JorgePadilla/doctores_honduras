# Seeds for Cities of Honduras by Department

cities_data = {
  "Atlántida" => [
    "La Ceiba", "Tela", "Jutiapa", "Arizona", "Esparta", "San Francisco", "El Porvenir"
  ],
  "Choluteca" => [
    "Choluteca", "Pespire", "San Lorenzo", "Marcovia", "Namasigüe", "Orocuina", "Pueblo Nuevo"
  ],
  "Colón" => [
    "Trujillo", "Tocoa", "Sonaguera", "Bonito Oriental", "Santa Fe", "Sabá", "Limón"
  ],
  "Comayagua" => [
    "Comayagua", "Siguatepeque", "La Libertad", "Taulabé", "San Jerónimo", "Esquías", "San José de Comayagua"
  ],
  "Copán" => [
    "Santa Rosa de Copán", "Copán Ruinas", "La Entrada", "Dulce Nombre", "San Antonio", "Cabañas", "Concepción"
  ],
  "Cortés" => [
    "San Pedro Sula", "Puerto Cortés", "Villanueva", "Choloma", "La Lima", "Potrerillos", "Pimienta"
  ],
  "El Paraíso" => [
    "Yuscarán", "Danlí", "El Paraíso", "Güinope", "Morocelí", "San Matías", "Oropolí"
  ],
  "Francisco Morazán" => [
    "Tegucigalpa", "Comayagüela", "Valle de Ángeles", "Santa Lucía", "Ojojona", "San Juan de Flores", "Talanga"
  ],
  "Gracias a Dios" => [
    "Puerto Lempira", "Brus Laguna", "Ahuas", "Juan Francisco Bulnes", "Ramón Villeda Morales"
  ],
  "Intibucá" => [
    "La Esperanza", "Intibucá", "Jesús de Otoro", "Magdalena", "San Juan", "San Miguelito", "Yamaranguila"
  ],
  "Islas de la Bahía" => [
    "Roatán", "Utila", "Guanaja", "José Santos Guardiola", "Santa Elena"
  ],
  "La Paz" => [
    "La Paz", "Marcala", "Yarula", "San Pedro de Tutule", "Santa Ana", "Cabañas", "Lauterique"
  ],
  "Lempira" => [
    "Gracias", "Lepaera", "Erandique", "San Manuel Colohete", "La Iguala", "San Sebastián", "Gualcince"
  ],
  "Ocotepeque" => [
    "Ocotepeque", "Sensenti", "San Marcos", "La Encarnación", "Concepción", "Santa Fe", "Lucerna"
  ],
  "Olancho" => [
    "Juticalpa", "Catacamas", "Campamento", "San Esteban", "Gualaco", "Dulce Nombre de Culmí", "Guata"
  ],
  "Santa Bárbara" => [
    "Santa Bárbara", "Quimistán", "San Pedro Sula", "Ilama", "Nueva Frontera", "Trinidad", "Gualala"
  ],
  "Valle" => [
    "Nacaome", "San Lorenzo", "Langue", "Amapala", "Aramecina", "Caridad", "Goascorán"
  ],
  "Yoro" => [
    "Yoro", "El Progreso", "Olanchito", "Jocón", "Morazán", "Victoria", "Santa Rita"
  ]
}

puts "Seeding cities..."

cities_data.each do |department_name, city_names|
  department = Department.find_by(name: department_name)
  if department
    city_names.each do |city_name|
      City.find_or_create_by!(name: city_name, department: department)
      puts "Created city: #{city_name} in #{department_name}"
    end
  else
    puts "Warning: Department #{department_name} not found!"
  end
end

puts "\nCities seeded successfully!"