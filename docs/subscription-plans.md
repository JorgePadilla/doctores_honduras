# Subscription Plans

This document describes the subscription plan system for Doctores Honduras.

## Overview

The platform uses a **per-profile-type** subscription model. Each profile type (doctor, hospital/clinic, vendor) has its own set of plans with three tiers: **gratis**, **profesional**, and **elite/premium**.

## Plan Structure

### Doctor Plans

| Tier | Name | Price | Features |
|------|------|-------|----------|
| gratis | Doctor Gratis | $0/mes | Perfil básico, Aparecer en directorio, Búsqueda de doctores, Sucursales (sin horarios ni teléfono) |
| profesional | Doctor Profesional | $12/mes | Perfil destacado, Estadísticas de visitas, Notificaciones, Soporte prioritario, Sucursales con horarios y teléfono |
| elite | Doctor Elite | $29/mes | Perfil premium, Video consulta (enlace Zoom/Meet), Estadísticas avanzadas, Notificaciones, Soporte prioritario, Posición destacada, Sucursales con horarios y teléfono |

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
| profile_type | string | "doctor", "hospital", or "vendor" (nil for legacy) |
| tier | string | "gratis", "profesional", "elite", or "premium" |
| position | integer | Display order (0, 1, 2) |
| stripe_product_id | string | Stripe product ID |
| stripe_price_id | string | Stripe price ID |

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

The seed file is idempotent - it uses `find_or_create_by` to avoid duplicates.

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

## Files Reference

| File | Purpose |
|------|---------|
| `app/models/subscription_plan.rb` | Plan model with Stripe methods |
| `app/models/subscription.rb` | User subscription model |
| `app/controllers/settings_controller.rb` | Plan display and subscription management |
| `app/controllers/stripe_controller.rb` | Stripe checkout and webhooks |
| `app/views/settings/subscription.html.erb` | Plan selection UI |
| `db/seeds/subscription_plans.rb` | Plan seeding |
