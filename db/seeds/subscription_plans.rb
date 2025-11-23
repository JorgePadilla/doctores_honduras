# Create subscription plans if they don't exist
puts "Creating subscription plans..."

if SubscriptionPlan.count == 0
  plans = [
    {
      name: "Plan Gratuito",
      price: 0,
      interval: "month",
      features: "Perfil sin aparecer en el directorio, Búsqueda de doctores, Listado de establecimientos",
      description: "Plan básico para usuarios que desean explorar la plataforma",
      visible: true
    },
    {
      name: "Plan Doctor",
      price: 5000, # 50.00 in cents
      interval: "month",
      features: "Perfil destacado en el directorio, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario",
      description: "La mejor opción para médicos que buscan maximizar su presencia online",
      visible: true
    },
    {
      name: "Plan Hospital",
      price: 30000, # 300.00 in cents
      interval: "month",
      features: "Múltiples perfiles para hospitales, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario, API de integración",
      description: "Diseñado para hospitales con múltiples especialistas",
      visible: true
    },
    {
      name: "Plan Proveedor",
      price: 15000, # 150.00 in cents
      interval: "month",
      features: "Perfil para proveedores médicos, Búsqueda avanzada, Listado de servicios, Notificaciones, Estadísticas de visitas",
      description: "Ideal para proveedores de servicios médicos especializados",
      visible: true
    }
  ]

  created_plans = SubscriptionPlan.create!(plans)
  puts "Created #{created_plans.size} subscription plans"
else
  puts "Subscription plans already exist, skipping seed"
end
