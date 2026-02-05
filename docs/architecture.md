# Architecture

## Authentication

Session-based authentication using `has_secure_password` (bcrypt). No Devise or third-party auth gem.

Key files:
- `app/controllers/concerns/authentication.rb` -- `require_authentication` before_action, cookie-based session lookup via `Current.session`
- `app/models/current.rb` -- `ActiveSupport::CurrentAttributes` storing the current session; delegates `user` to session
- `app/models/session.rb` -- Tracks IP address and user agent per login
- `app/controllers/sessions_controller.rb` -- Login/logout
- `app/controllers/users_controller.rb` -- Registration (signup)
- `app/controllers/passwords_controller.rb` -- Password reset flow

Controllers opt out of auth with `allow_unauthenticated_access`.

## Models

### Core domain

| Model | Table | Key fields | Relationships |
|---|---|---|---|
| `User` | `users` | email, password_digest, profile_type, onboarding_completed, admin, language | has_one :doctor_profile, has_many :establishments, has_one :supplier, has_one :subscription, has_many :sessions |
| `DoctorProfile` | `doctor_profiles` | name, description, image_url, medical_license, hidden, video_consultation_url | belongs_to :user, :specialty, :subspecialty, :department, :city; has_many :establishments (through doctor_establishments), :services (through doctor_services) |
| `Establishment` | `establishments` | name, est_type, address, phone, map_link, logo_url, building_image_url, description, website, email | belongs_to :user, :department, :city; has_many :doctor_profiles (through doctor_establishments), :specialties (through establishment_specialties), :services (through establishment_services) |
| `Supplier` | `suppliers` | name, address, phone, email, description, logo_url, category, website, featured, hidden | belongs_to :user, :department, :city; has_many :products, :lead_contacts |
| `Product` | `products` | name, sku, description, price, category, image_url, active, featured | belongs_to :supplier |
| `LeadContact` | `lead_contacts` | name, email, phone, organization, message, status (new/contacted/converted) | belongs_to :supplier |

### Subscriptions

| Model | Table | Key fields |
|---|---|---|
| `SubscriptionPlan` | `subscription_plans` | name, price (cents), interval (month/year), features, profile_type, tier, position, stripe_price_id, stripe_product_id |
| `Subscription` | `subscriptions` | status (active/canceled/past_due), plan_name, stripe_subscription_id, stripe_customer_id, current_period_start, current_period_end, cancel_at |

`SubscriptionPlan` has a unique index on `(profile_type, tier)`. Tiers per profile type:
- **doctor**: gratis, profesional, elite
- **hospital** (also used by clinic): gratis, profesional, premium
- **vendor**: gratis, profesional, premium

### Geography

| Model | Table | Notes |
|---|---|---|
| `Department` | `departments` | Honduras departamentos; unique name |
| `City` | `cities` | belongs_to :department |

### Reference data

| Model | Table | Notes |
|---|---|---|
| `Specialty` | `specialties` | Medical specialties; linked to doctors and establishments |
| `Subspecialty` | `subspecialties` | belongs_to :specialty |
| `Service` | `services` | Medical services/tags; linked to doctors and establishments |

### Join tables

- `doctor_establishments` -- DoctorProfile <-> Establishment
- `doctor_services` -- DoctorProfile <-> Service (unique index)
- `establishment_services` -- Establishment <-> Service (unique index)
- `establishment_specialties` -- Establishment <-> Specialty (unique index)

### Supporting

| Model | Table |
|---|---|
| `Session` | `sessions` -- login sessions (user_id, ip_address, user_agent) |
| `NotificationPreference` | `notification_preferences` -- per-user email/marketing toggles |
| `PaymentHistory` | `payment_histories` -- amount, status, payment_method, description |
| `Article` | `articles` -- title, content, author_id, published_at |

## Controllers

### Public

| Controller | Routes | Purpose |
|---|---|---|
| `HomeController` | `GET /` | Landing page |
| `DoctorsController` | `GET /doctors`, `GET /doctors/:id` | Doctor directory with search, specialty/service filters, pagination |
| `EstablishmentsController` | `GET /hospitales-y-clinicas` | Hospital/clinic directory |
| `SuppliersController` | `GET /proveedores`, `GET /proveedores/:id` | Supplier directory |
| `ProductsController` | nested under suppliers | Public product listing |
| `LeadContactsController` | `POST /proveedores/:supplier_id/contacto` | Submit lead contact form (no auth required) |
| `SpecialtiesController` | `GET /specialties/:id/subspecialties` | Returns subspecialties for a specialty (AJAX) |

### Authenticated

| Controller | Purpose |
|---|---|
| `DashboardController` | Per-profile-type dashboard with profile completeness score |
| `OnboardingController` | Two-step onboarding: profile_type_selection -> basic_info -> complete (auto-assigns free plan) |
| `ProfilesController` | Edit own profile |
| `SettingsController` | Account, subscription management, notifications, security (sessions), language |
| `PaymentsController` | Shows Stripe payment form with client secret |

### Vendor namespace (`Vendor::`)

All inherit from `Vendor::BaseController` which enforces `profile_type == "vendor"` and provides `current_supplier` / `current_subscription_tier` / `paid_plan?` helpers.

| Controller | Purpose |
|---|---|
| `Vendor::ProfilesController` | Edit supplier profile |
| `Vendor::ProductsController` | CRUD products. Free plan capped at 5 products (`check_product_limit`). |
| `Vendor::LeadsController` | View/update lead contacts. Requires paid plan (`require_paid_plan`). |

### Stripe

| Controller | Purpose |
|---|---|
| `StripeController` | `create_checkout_session` (redirects to Stripe Checkout), `success`/`cancel` callbacks, `webhook` endpoint handling checkout.session.completed, invoice.paid, invoice.payment_failed, customer.subscription.deleted, customer.subscription.updated |

### Admin namespace (`Admin::`)

| Controller | Purpose |
|---|---|
| `Admin::DashboardController` | Admin overview, user list, doctor list, subscription list, toggle doctor visibility |

## Services

### S3UploadService

`app/services/s3_upload_service.rb`

Uploads files to AWS S3 and returns the public URL. Uses a bucket-level policy for public reads (not per-object ACLs). Files are stored under `doctor_profiles/` prefix with timestamped filenames.

Required env vars: `AWS_BUCKET`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.

Called from `DoctorProfile#upload_image_to_s3` as a `before_save` callback when `image_file` is present.

## Internationalization

`app/controllers/concerns/internationalization.rb`

Locale resolution order: session -> user.language -> params[:locale] -> Accept-Language header -> default (`:es`).

Supported locales: `es` (Spanish), `en` (English). Locale is stored in session, not in URL.

## Authorization

Uses Pundit (`app/policies/application_policy.rb`). Admin check via `User#admin?` boolean column.

## Frontend

- Tailwind CSS 4.2 via `tailwindcss-rails` gem
- Propshaft asset pipeline
- Hotwire: Turbo (turbo-frames, turbo-streams) + Stimulus
- Import maps for JS (no webpack/esbuild)
- ViewComponent for reusable components
