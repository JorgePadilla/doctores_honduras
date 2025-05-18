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
      price: 5000, # 50.00 in cents
      interval: "month",
      features: "Perfil destacado en el directorio, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario",
      description: "La mejor opción para profesionales que buscan maximizar su presencia online"
    },
    {
      name: "Plan Básico",
      price: 3000, # 30.00 in cents
      interval: "month",
      features: "Perfil en el directorio, Búsqueda avanzada, Listado de establecimientos, Notificaciones",
      description: "Ideal para profesionales que desean mayor visibilidad"
    },
    {
      name: "Plan Institucional",
      price: 30000, # 300.00 in cents
      interval: "month",
      features: "Múltiples perfiles para hospitales y clínicas, Búsqueda avanzada, Listado de establecimientos, Notificaciones, Estadísticas de visitas, Soporte prioritario, API de integración",
      description: "Diseñado para clínicas y hospitales con múltiples especialistas"
    }
  ]

  created_plans = SubscriptionPlan.create!(plans)
  puts "Created #{created_plans.size} subscription plans"
else
  puts "Subscription plans already exist, skipping seed"
end
