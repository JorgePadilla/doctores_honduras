module NavigationHelper
  # Ítems del menú de usuario, agrupados por sección. Encapsula el gating que
  # antes vivía inline en `_navbar.html.erb`. Cada ítem:
  #   { label:, path:, icon:, section: }  (+ admin: true para resaltar Panel admin)
  # Secciones (orden de render): :work (uso diario) · :account (identidad/cuenta)
  # · :mode (cambio de modo). "Cerrar sesión" se renderiza aparte (button_to DELETE).
  #
  # Fase 1: se conservan "Panel de control" y "Configuración"; la fusión en un
  # solo hub "Mi cuenta" llega en la Fase 2.
  def user_menu_items(user)
    items = []
    pt = user.profile_type

    # ── :work — herramientas de uso diario, por tipo ──
    if agenda_menu_visible?(user)
      items << { label: "Agenda", path: agenda_appointments_path, icon: :calendar_days, section: :work }
    end
    if pt == "vendor"
      items << { label: "Mis productos", path: vendor_products_path, icon: :shopping_bag, section: :work }
      items << { label: "Contactos", path: vendor_leads_path, icon: :envelope, section: :work }
    end
    if pt == "paciente"
      items << { label: "Mis citas", path: paciente_appointments_path, icon: :calendar_days, section: :work }
    end

    # ── :account — identidad y cuenta ──
    items << profile_menu_item(user)
    items << { label: "Panel de control", path: dashboard_path, icon: :squares_2x2, section: :account }
    items << { label: "Configuración", path: settings_path, icon: :cog_6_tooth, section: :account }

    # ── :mode — cambio de modo ──
    if user.admin?
      items << { label: "Panel admin", path: admin_dashboard_path, icon: :shield_check, section: :mode, admin: true }
    end

    items
  end

  # Agenda visible para doctores profesional/elite o cualquier secretaria activa.
  def agenda_menu_visible?(user)
    (user.profile_type == "doctor" && user.subscription&.subscription_plan&.tier.in?(%w[profesional elite])) ||
      user.secretary?
  end

  # "Mi perfil" con un destino predecible por tipo (arregla el overload y el
  # dead-end del viewer, que ahora ve "Crear mi perfil").
  def profile_menu_item(user)
    case user.profile_type
    when "doctor"
      { label: "Mi perfil", path: profile_path, icon: :user_circle, section: :account }
    when "hospital", "clinic"
      { label: "Mi perfil", path: edit_establishment_profile_path, icon: :user_circle, section: :account }
    when "vendor"
      { label: "Mi perfil", path: vendor_profile_path, icon: :user_circle, section: :account }
    when "paciente"
      { label: "Mi perfil", path: paciente_profile_path, icon: :user_circle, section: :account }
    else # viewer / nil
      { label: "Crear mi perfil", path: onboarding_profile_type_path, icon: :sparkles, section: :account }
    end
  end

  # Nombre visible del usuario para el header del menú: nombre del perfil si
  # existe, si no el email (la tabla users no tiene columna name).
  def menu_display_name(user)
    name =
      case user.profile_type
      when "doctor" then user.doctor_profile&.display_name
      when "hospital", "clinic" then user.establishments.first&.name
      when "vendor" then user.supplier&.name
      when "paciente" then user.patient_profile&.name
      end
    name.presence || user.email
  end

  # Iniciales para el avatar (1-2 letras).
  def menu_avatar_initials(user)
    source = menu_display_name(user)
    return source[0, 1].upcase if source.include?("@")

    source.split.first(2).map { |w| w[0] }.join.upcase
  end

  # Badge de plan por tier (color de sistema): gratis=slate, profesional=sky,
  # elite/premium=amber.
  def menu_plan_badge(user)
    tier = user.subscription&.subscription_plan&.tier.presence || "gratis"
    case tier
    when "profesional"
      { label: "Profesional", classes: "bg-sky-100 text-sky-700 dark:bg-sky-900/40 dark:text-sky-300" }
    when "elite"
      { label: "Elite", classes: "bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-300" }
    when "premium"
      { label: "Premium", classes: "bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-300" }
    else
      { label: "Gratis", classes: "bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-300" }
    end
  end
end
