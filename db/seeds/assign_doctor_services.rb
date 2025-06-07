# Asignar servicios a los doctores existentes
puts "Asignando servicios a los doctores..."

# Obtener todos los doctores y servicios
doctors = DoctorProfile.all
services = Service.all

# Para cada doctor, asignar entre 3 y 8 servicios aleatorios
doctors.each do |doctor|
  # Determinar cuántos servicios asignar a este doctor (entre 3 y 8)
  num_services = rand(3..8)
  
  # Seleccionar servicios aleatorios para este doctor
  doctor_services = services.sample(num_services)
  
  # Crear las asociaciones
  doctor_services.each do |service|
    DoctorService.find_or_create_by(doctor_profile: doctor, service: service)
  end
  
  puts "  - Asignados #{num_services} servicios al doctor #{doctor.name}"
end

puts "Servicios asignados exitosamente a #{doctors.count} doctores"
