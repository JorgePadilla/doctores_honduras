#!/usr/bin/env ruby
# Este script actualiza los logos de los establecimientos

# Mapeo de establecimientos con sus URLs de logos
logos = {
  'Policlínica del Atlántico' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=PA',
  'Clínicas Millenium' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CM',
  'Hospital Escuela' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HE',
  'Hospital San Felipe' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HSF',
  'Hospital Militar' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HM',
  'Hospital Viera' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HV',
  'Centro Médico Hondureño' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CMH',
  'Centro Especializado San Jorge' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CESJ',
  'Clínica Médica Cristiana' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CMC',
  'Clínica La Salud' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CLS',
  'Centro Médico La Paz' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CMLP',
  'Hospital D\'Antoni' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HDA',
  'Clínica Santa María' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CSM',
  'Centro Médico Comayagua' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=CMC',
  'Hospital Regional del Norte' => 'https://placehold.co/200x200/00bfff/ffffff.png?text=HRN'
}

# Actualizar cada establecimiento con su logo correspondiente
logos.each do |name, logo_url|
  establishment = Establishment.find_by(name: name)
  if establishment
    establishment.update(logo_url: logo_url)
    puts "Actualizado logo para: #{name}"
  else
    puts "No se encontró: #{name}"
  end
end

puts "Proceso completado. Se actualizaron #{logos.count} logos."
