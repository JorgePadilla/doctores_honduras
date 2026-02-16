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

new_plans = [
  # Doctor plans
  { profile_type: "doctor", tier: "gratis", name: "Doctor Gratis", price: 0, interval: "month", position: 0,
    features: "Perfil básico, Aparecer en directorio, Búsqueda de doctores, Sucursales (sin horarios ni teléfono)",
    description: "Plan gratuito para doctores" },
  { profile_type: "doctor", tier: "profesional", name: "Doctor Profesional", price: 1200, interval: "month", position: 1,
    features: "Perfil destacado, Estadísticas de visitas, Notificaciones, Soporte prioritario, Sucursales con horarios y teléfono",
    description: "Ideal para doctores que buscan mayor visibilidad" },
  { profile_type: "doctor", tier: "elite", name: "Doctor Elite", price: 2900, interval: "month", position: 2,
    features: "Perfil premium, Video consulta (enlace Zoom/Meet), Estadísticas avanzadas, Notificaciones, Soporte prioritario, Posición destacada, Sucursales con horarios y teléfono",
    description: "La mejor opción para doctores: incluye enlace de video consulta" },

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

new_plans.each do |plan_attrs|
  SubscriptionPlan.find_or_create_by!(profile_type: plan_attrs[:profile_type], tier: plan_attrs[:tier]) do |plan|
    plan.assign_attributes(plan_attrs)
  end
end

puts "Per-profile-type plans seeded: #{SubscriptionPlan.where.not(profile_type: nil).count} plans"
