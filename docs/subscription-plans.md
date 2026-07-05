# Subscription Plans

This document describes the subscription plan system for Doctores Honduras.

## Overview

The platform uses a **per-profile-type** subscription model. Each profile type (doctor, hospital/clinic, vendor, paciente) has its own set of plans. Doctor has **gratis**, **profesional**, and **three Elite tiers** (differentiated by clinical-record capacity). Hospital/clinic and vendor have **gratis**, **profesional**, and **premium**. Paciente has a single **gratis** tier.

## Plan Structure

### Doctor Plans

The three Elite tiers all share `tier: "elite"` (so tier-based gating is unchanged) and are differentiated by **`patient_limit`** — the number of clinical records (registros) allowed by the **Expediente Clínico Digital**, an Elite-exclusive feature. Every tier has a numeric ceiling (no unlimited tier).

| Tier | Name | Price | Registros (patient_limit) | Features |
|------|------|-------|---------------------------|----------|
| gratis | Doctor Gratis | $0/mes | — | Perfil básico, Aparecer en directorio, Búsqueda de doctores, Sucursales (sin horarios ni teléfono) |
| profesional | Doctor Profesional | $12/mes | — | Perfil destacado, Agenda Médica (gestión manual), Asignar secretaria para agendar citas, Estadísticas de visitas, Notificaciones, Soporte prioritario, Sucursales con horarios y teléfono |
| elite | Doctor Elite | $35/mes | 5,000 | **Expediente Clínico Digital (hasta 5,000 registros)**, Alerta de alergias e info crítica, Historial clínico consolidado, Perfil premium, Agenda Médica, Reservas en línea (autoservicio paciente), Asignar secretaria, Video consulta (enlace Zoom/Meet), Estadísticas avanzadas, Notificaciones, Posición destacada, Sucursales con horarios y teléfono, Soporte prioritario |
| elite | Doctor Elite 25K | $69/mes | 25,000 | Todo lo de Elite, con **Expediente Clínico Digital hasta 25,000 registros** |
| elite | Doctor Elite 100K | $129/mes | 100,000 | Todo lo de Elite, con **Expediente Clínico Digital hasta 100,000 registros** y Soporte dedicado |

**Pricing rationale (2026):** research de mercado de EMR/EHR — soluciones LATAM (SaludTotal, MediSystem, Huli, ARMED) rondan **$14–131 USD/mes**; EMR de EE. UU. promedian ~$382/mes. La escala Elite ($35 → $69 → $129) posiciona el nivel de entrada por debajo de la mediana LATAM y el tope dentro del rango, escalando por capacidad de registros. Todos los niveles tienen techo (nada ilimitado).

### Hospital/Clinic Plans

| Tier | Name | Price | Features |
|------|------|-------|----------|
| gratis | Hospital/Clínica Gratis | $0/mes | Perfil básico, Aparecer en directorio, Listado de servicios |
| profesional | Hospital/Clínica Profesional | $25/mes | Perfil destacado, Estadísticas de visitas, Múltiples doctores, Notificaciones, Soporte prioritario |
| premium | Hospital/Clínica Premium | $75/mes | Perfil premium, Estadísticas avanzadas, Doctores ilimitados, API de integración, Soporte dedicado |

### Vendor Plans

| Tier | Name | Price | Features |
|------|------|-------|----------|
| gratis | Proveedor Gratis | $0/mes | Perfil básico, Hasta 5 productos, Aparecer en directorio |
| profesional | Proveedor Profesional | $20/mes | Perfil destacado, Productos ilimitados, Contactos de clientes, Estadísticas, Soporte prioritario |
| premium | Proveedor Premium | $60/mes | Perfil premium, Productos ilimitados, Contactos ilimitados, Estadísticas avanzadas, Posición destacada, Soporte dedicado |

### Paciente Plans

| Tier | Name | Price | Features |
|------|------|-------|----------|
| gratis | Paciente Gratis | $0/mes | Busqueda de doctores, Gestion de citas, Historial medico |

Patients have a single free plan. There is no paid upgrade path for patients.

## How Plans Are Displayed

Plans are shown on the **Settings > Subscription** page (`/settings/subscription`).

The system determines which plans to show based on the user's `profile_type`:

```ruby
# In SettingsController#subscription
plan_profile = @user.profile_type == "clinic" ? "hospital" : @user.profile_type
if plan_profile.present?
  @plans = SubscriptionPlan.for_profile_type(plan_profile).ordered
else
  @plans = SubscriptionPlan.where(profile_type: nil)  # Legacy plans
end
```

**Note**: Clinics use the same plans as hospitals (mapped via `plan_profile`).

## Database Schema

### SubscriptionPlan Model

| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key |
| name | string | Display name (e.g., "Doctor Profesional") |
| price | integer | Price in cents (e.g., 1200 = $12.00) |
| interval | string | Billing interval: "month" or "year" |
| features | text | Comma-separated list of features |
| description | text | Plan description |
| profile_type | string | "doctor", "hospital", "vendor", or "paciente" (nil for legacy) |
| tier | string | "gratis", "profesional", "elite", or "premium" |
| patient_limit | integer | Registros (clinical records) allowed. NULL = Expediente Clínico no aplica al plan. Used to differentiate the 3 Elite tiers. |
| position | integer | Display order (0, 1, 2, 3, 4…) |
| stripe_product_id | string | Stripe product ID |
| stripe_price_id | string | Stripe price ID |

**Index note:** `(profile_type, tier)` is indexed but **no longer unique** — the 3 Elite tiers share `("doctor", "elite")`. Uniqueness is now effectively by `name`.

### Key Scopes

```ruby
SubscriptionPlan.for_profile_type("doctor")  # Returns doctor plans
SubscriptionPlan.ordered                      # Orders by position
```

## Payment Integration

### Stripe Checkout

Paid plans use Stripe Checkout for payment:

1. User clicks "Suscribirse con Tarjeta"
2. System creates Stripe Checkout session via `StripeController#create_checkout_session`
3. User completes payment on Stripe
4. Stripe webhook updates subscription status

### Free Plans

Free plans are activated directly without payment:

```ruby
# POST /settings/subscribe?plan_id=X
SettingsController#subscribe -> activate_subscription(plan)
```

## Subscription Model

### Status Values

| Status | Description |
|--------|-------------|
| active | Currently active subscription |
| canceled | Canceled but still active until period end |
| past_due | Payment failed |
| unpaid | Never paid |

### Key Methods

```ruby
subscription.active?        # Returns true if status is "active"
subscription.plan_name      # Returns the plan's display name
subscription.current_period_end  # When current billing period ends
```

## Seeding Plans

Plans are seeded via `db/seeds/subscription_plans.rb`:

```bash
bin/rails db:seed
```

The seed file is idempotent — it **upserts by `name`** (`find_or_initialize_by(name:)` + `save!`), so re-running the seeds also **updates** prices, `patient_limit`, and features on existing rows. (It can no longer key on `(profile_type, tier)` because the 3 Elite tiers share that pair.)

## Legacy Plans

There are 6 legacy plans (with `profile_type: nil`) from the old system:
- Plan Gratuito
- Plan Premium
- Plan Básico
- Plan Institucional
- Plan Doctor
- Plan Hospital

Users without a `profile_type` set will see these legacy plans. New users who complete onboarding will always have a `profile_type` and see the new per-profile-type plans.

## Feature Gating

### Doctor Sucursales (Branches)

All doctor plans can add sucursales (branch locations), but phone numbers and schedules are gated:

| Feature | Gratis | Profesional | Elite |
|---------|--------|-------------|-------|
| Sucursales | 1 max | Ilimitadas | Ilimitadas |
| Branch name & address | Yes | Yes | Yes |
| Department & city | Yes | Yes | Yes |
| Map link | Yes | Yes | Yes |
| Phone number | No | Yes | Yes |
| Horarios (schedules) | No | Yes | Yes |

Server-side enforcement in `ProfilesController#strip_paid_branch_fields` strips phone/schedule params and limits free-tier doctors to 1 branch.

### Vendor Product Limit

Free vendor plan limits products to 5:

```ruby
# In Vendor::ProductsController
if current_user.subscription&.subscription_plan&.tier == "gratis"
  # Show upgrade prompt if at limit
end
```

### Lead Access

Leads are only visible to paid vendor plans:

```ruby
# In dashboard
if subscription&.subscription_plan&.price&.positive?
  # Show leads count
end
```

### Agenda Medica (Doctor)

El sistema de agenda permite a los doctores gestionar citas. El acceso depende del tier:

| Feature | Gratis | Profesional | Elite |
|---------|--------|-------------|-------|
| Agenda/citas | No | Si (gestión manual) | Si |
| Asignar secretaria para agendar | No | Si | Si |
| Reservas en línea (autoservicio) | No | No | Si |

- **Profesional** (sin autoservicio): el doctor y sus secretarias pueden crear, editar y cancelar citas manualmente desde `/agenda/appointments`. Pueden configurar duración de citas y buffer entre citas. Los pacientes **no** pueden reservar por su cuenta.
- **Elite** (autoservicio + secretarias): además de todo lo anterior, el doctor puede activar "Reservas en línea" (`public_booking_enabled`) para que pacientes reserven citas directamente desde el perfil público del doctor. También puede asignar secretarias para gestión manual.

### Expediente Clínico Digital (Elite only)

El **Expediente Clínico Digital** (ficha clínica: alergias, crónicos, medicamentos, tipo de sangre, antecedentes; alerta de info crítica; historial consolidado) es **exclusivo del tier Elite**. Los 3 niveles Elite se diferencian por el **techo de registros** (`patient_limit`):

| Tier | Registros (patient_limit) |
|------|---------------------------|
| Doctor Elite | 5,000 |
| Doctor Elite 25K | 25,000 |
| Doctor Elite 100K | 100,000 |

Todos los niveles tienen un tope numérico — no hay nivel ilimitado. Como los 3 comparten `tier: "elite"`, el gating de acceso a la función se resuelve con `tier == "elite"` (igual que Agenda/reservas); el `patient_limit` se aplicará al crear registros para hacer cumplir la capacidad contratada.

> **Estado:** el núcleo del expediente **ya está implementado** — modelo `Patient` canónico (por-médico, cubre walk-ins), ficha clínica `ClinicalRecord` (CRUD Elite), alerta de alergias (en la ficha y en el detalle de la cita), historial consolidado, y **enforcement del `patient_limit`** al crear fichas (bloquea al alcanzar el techo del nivel Elite). Ver `docs/backlog-feedback-medico.md`, sección "2º audio" (F1, G1, G2, G3 = ✅; H–I pendientes). Gate de acceso: `AgendaAuthorization#require_elite`; controlador `Agenda::ClinicalRecordsController`.

Server-side enforcement:
- `AgendaAuthorization` concern verifica que el doctor tenga tier != "gratis" para acceder a `/agenda/*`
- `BookingsController` verifica tier == "elite" + `public_booking_enabled` para booking publico
- Navbar muestra link "Agenda" solo para doctores con plan profesional/elite y secretarias

## Files Reference

| File | Purpose |
|------|---------|
| `app/models/subscription_plan.rb` | Plan model with Stripe methods |
| `app/models/subscription.rb` | User subscription model |
| `app/controllers/settings_controller.rb` | Plan display and subscription management |
| `app/controllers/stripe_controller.rb` | Stripe checkout and webhooks |
| `app/views/settings/subscription.html.erb` | Plan selection UI |
| `db/seeds/subscription_plans.rb` | Plan seeding |
| `app/controllers/concerns/agenda_authorization.rb` | Agenda access control by tier |
| `app/controllers/agenda/base_controller.rb` | Agenda base controller with tier gating |
| `app/controllers/bookings_controller.rb` | Public booking (elite only) |
