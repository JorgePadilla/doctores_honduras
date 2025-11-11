# Seeds for Departments of Honduras
departments_data = [
  "Atlántida",
  "Choluteca",
  "Colón",
  "Comayagua",
  "Copán",
  "Cortés",
  "El Paraíso",
  "Francisco Morazán",
  "Gracias a Dios",
  "Intibucá",
  "Islas de la Bahía",
  "La Paz",
  "Lempira",
  "Ocotepeque",
  "Olancho",
  "Santa Bárbara",
  "Valle",
  "Yoro"
]

departments_data.each do |department_name|
  Department.find_or_create_by!(name: department_name)
  puts "Created department: #{department_name}"
end

puts "\nDepartments seeded successfully!"