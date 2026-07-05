# Create subscription plans if they don't exist
puts "Creating subscription plans..."

if SubscriptionPlan.count == 0
  plans = [
    {
      name: "Plan Gratuito",
      price: 0,
      interval: "month",
      features: "Perfil sin aparecer en el directorio, Búsqueda de doctores, Listado de establecimientos",
      description: "Plan básico para usuarios que desean explorar la plataforma"
    },
    {
      name: "Plan Premium",
      price: 5000,
      interval: "month",
      features: "Perfil destacado en el directorio, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario",
      description: "La mejor opción para profesionales que buscan maximizar su presencia online"
    },
    {
      name: "Plan Básico",
      price: 3000,
      interval: "month",
      features: "Perfil en el directorio, Búsqueda avanzada, Listado de establecimientos, Notificaciones",
      description: "Ideal para profesionales que desean mayor visibilidad"
    },
    {
      name: "Plan Institucional",
      price: 30000,
      interval: "month",
      features: "Múltiples perfiles para hospitales y clínicas, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario, API de integración",
      description: "Diseñado para clínicas y hospitales con múltiples especialistas"
    }
  ]

  SubscriptionPlan.create!(plans)
  puts "Created #{SubscriptionPlan.count} legacy subscription plans"
end

# Seed new per-profile-type plans (idempotent via find_or_create_by)
puts "Seeding per-profile-type subscription plans..."

# Bloque común de funciones Elite. El Expediente Clínico Digital es exclusivo
# de Elite; los 3 niveles se diferencian por el techo de registros (patient_limit).
elite_base_features = [
  "Alerta de alergias e info crítica",
  "Historial clínico consolidado",
  "Perfil premium",
  "Agenda Médica",
  "Reservas en línea (autoservicio paciente)",
  "Asignar secretaria para agendar citas",
  "Video consulta (enlace Zoom/Meet)",
  "Estadísticas avanzadas",
  "Notificaciones",
  "Posición destacada",
  "Sucursales con horarios y teléfono"
]

elite_features = ->(limit_label, support) {
  ["Expediente Clínico Digital (#{limit_label})", *elite_base_features, support].join(", ")
}

new_plans = [
  # Doctor plans
  { profile_type: "doctor", tier: "gratis", name: "Doctor Gratis", price: 0, interval: "month", position: 0,
    features: "Perfil básico, Aparecer en directorio, Búsqueda de doctores, Sucursales (sin horarios ni teléfono)",
    description: "Plan gratuito para doctores" },
  { profile_type: "doctor", tier: "profesional", name: "Doctor Profesional", price: 1200, interval: "month", position: 1,
    features: "Perfil destacado, Agenda Médica (gestión manual), Asignar secretaria para agendar citas, Estadísticas de visitas, Notificaciones, Soporte prioritario, Sucursales con horarios y teléfono",
    description: "Ideal para doctores que buscan mayor visibilidad" },

  # Elite — 3 niveles por capacidad de Expediente Clínico Digital (todos con techo).
  { profile_type: "doctor", tier: "elite", name: "Doctor Elite", price: 3500, interval: "month", position: 2,
    patient_limit: 5_000,
    features: elite_features.("hasta 5,000 registros", "Soporte prioritario"),
    description: "Expediente Clínico Digital para consultorios: hasta 5,000 registros de pacientes." },
  { profile_type: "doctor", tier: "elite", name: "Doctor Elite 25K", price: 6900, interval: "month", position: 3,
    patient_limit: 25_000,
    features: elite_features.("hasta 25,000 registros", "Soporte prioritario"),
    description: "Para clínicas con alto volumen: hasta 25,000 registros de pacientes." },
  { profile_type: "doctor", tier: "elite", name: "Doctor Elite 100K", price: 12900, interval: "month", position: 4,
    patient_limit: 100_000,
    features: elite_features.("hasta 100,000 registros", "Soporte dedicado"),
    description: "Máxima capacidad: hasta 100,000 registros de pacientes." },

  # Hospital/Clinic plans
  { profile_type: "hospital", tier: "gratis", name: "Hospital/Clínica Gratis", price: 0, interval: "month", position: 0,
    features: "Perfil básico, Aparecer en directorio, Listado de servicios",
    description: "Plan gratuito para hospitales y clínicas" },
  { profile_type: "hospital", tier: "profesional", name: "Hospital/Clínica Profesional", price: 2500, interval: "month", position: 1,
    features: "Perfil destacado, Estadísticas de visitas, Múltiples doctores, Notificaciones, Soporte prioritario",
    description: "Ideal para clínicas y hospitales medianos" },
  { profile_type: "hospital", tier: "premium", name: "Hospital/Clínica Premium", price: 7500, interval: "month", position: 2,
    features: "Perfil premium, Estadísticas avanzadas, Doctores ilimitados, API de integración, Soporte dedicado",
    description: "Diseñado para grandes hospitales y clínicas" },

  # Vendor plans
  { profile_type: "vendor", tier: "gratis", name: "Proveedor Gratis", price: 0, interval: "month", position: 0,
    features: "Perfil básico, Hasta 5 productos, Aparecer en directorio",
    description: "Plan gratuito para proveedores médicos" },
  { profile_type: "vendor", tier: "profesional", name: "Proveedor Profesional", price: 2000, interval: "month", position: 1,
    features: "Perfil destacado, Productos ilimitados, Contactos de clientes, Estadísticas, Soporte prioritario",
    description: "Ideal para proveedores que buscan expandir su alcance" },
  { profile_type: "vendor", tier: "premium", name: "Proveedor Premium", price: 6000, interval: "month", position: 2,
    features: "Perfil premium, Productos ilimitados, Contactos ilimitados, Estadísticas avanzadas, Posición destacada, Soporte dedicado",
    description: "La mejor opción para proveedores: máxima visibilidad y leads" },

  # Patient plan
  { profile_type: "paciente", tier: "gratis", name: "Paciente Gratis", price: 0, interval: "month", position: 0,
    features: "Búsqueda de doctores, Gestión de citas, Historial médico",
    description: "Plan gratuito para pacientes" }
]

# Upsert por nombre (único por plan). Con 3 niveles Elite ya no se puede usar
# (profile_type, tier) como clave, y así los precios/límites/features se
# actualizan en filas existentes al re-correr las seeds.
new_plans.each do |plan_attrs|
  plan = SubscriptionPlan.find_or_initialize_by(name: plan_attrs[:name])
  plan.assign_attributes(plan_attrs)
  plan.save!
end

puts "Per-profile-type plans seeded: #{SubscriptionPlan.where.not(profile_type: nil).count} plans"
