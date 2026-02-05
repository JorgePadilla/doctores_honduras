# Database Schema

PostgreSQL database. Schema version: `2026_02_04_000006`.

## users

Primary table for all accounts.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| email | string | unique index, normalized (strip + downcase) |
| password_digest | string | bcrypt hash |
| profile_type | string | `doctor`, `hospital`, `clinic`, `vendor`, or NULL (viewer) |
| onboarding_completed | boolean | default false |
| admin | boolean | |
| language | string | `es` or `en`, default `es` |
| two_factor_secret | string | reserved for 2FA |
| created_at, updated_at | datetime | |

## doctor_profiles

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| name | string | required |
| description | text | |
| website | string | |
| image_url | string | S3 URL or external URL |
| medical_license | string | |
| state | string | |
| subspecialty | string | legacy text field |
| hidden | boolean | hides from public directory |
| specialty_id | bigint | FK -> specialties |
| subspecialty_id | bigint | FK -> subspecialties |
| department_id | bigint | FK -> departments, required |
| city_id | bigint | FK -> cities, required |
| video_consultation_url | string | Zoom/Meet link (elite plan) |
| created_at, updated_at | datetime | |

## establishments

Hospitals, clinics, and medical centers.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required |
| est_type | string | required (`Hospital`, `Clinica`, `Centro Medico`) |
| address | string | required |
| phone | string | |
| map_link | string | Google Maps URL |
| image_url | string | |
| logo_url | string | |
| building_image_url | string | |
| user_id | bigint | FK -> users (owner, optional) |
| department_id | bigint | FK -> departments |
| city_id | bigint | FK -> cities |
| description | text | |
| website | string | |
| email | string | |
| created_at, updated_at | datetime | |

## suppliers

Medical equipment/supply vendors.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required |
| address | string | |
| phone | string | required |
| email | string | |
| description | text | |
| logo_url | string | |
| category | string | |
| website | string | |
| user_id | bigint | FK -> users (owner) |
| department_id | bigint | FK -> departments |
| city_id | bigint | FK -> cities |
| featured | boolean | default false |
| hidden | boolean | default false |
| created_at, updated_at | datetime | |

## products

Supplier product catalog.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required |
| sku | string | required, unique |
| description | text | |
| price | decimal | |
| category | string | required |
| image_url | string | |
| supplier_id | bigint | FK -> suppliers |
| active | boolean | default true |
| featured | boolean | default false |
| created_at, updated_at | datetime | |

## lead_contacts

Inquiries from potential customers to suppliers.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| supplier_id | bigint | FK -> suppliers |
| name | string | required |
| email | string | required, validated |
| phone | string | |
| organization | string | |
| message | text | |
| status | string | `new` (default), `contacted`, `converted` |
| created_at, updated_at | datetime | |

## subscription_plans

Defines available plans per profile type and tier.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required |
| description | text | |
| price | integer | in cents (0 = free) |
| interval | string | `month` or `year` |
| features | text | comma-separated feature list |
| profile_type | string | `doctor`, `hospital`, `vendor` |
| tier | string | `gratis`, `profesional`, `elite`, `premium` |
| position | integer | display order, default 0 |
| stripe_price_id | string | unique index |
| stripe_product_id | string | unique index |
| visible | boolean | |
| created_at, updated_at | datetime | |

Unique index on `(profile_type, tier)`.

## subscriptions

One per user. Links a user to their active plan.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users, unique (one subscription per user) |
| subscription_plan_id | bigint | FK -> subscription_plans |
| plan | string | legacy |
| plan_name | string | |
| status | string | `active`, `canceled`, `past_due` |
| stripe_subscription_id | string | unique index |
| stripe_customer_id | string | indexed |
| current_period_start | datetime | |
| current_period_end | datetime | |
| cancel_at | datetime | scheduled cancellation |
| next_billing_at | datetime | legacy |
| created_at, updated_at | datetime | |

## sessions

Tracks login sessions.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| ip_address | string | |
| user_agent | string | |
| created_at, updated_at | datetime | |

## departments

Honduras departamentos (states/regions).

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required, unique |
| created_at, updated_at | datetime | |

## cities

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | |
| department_id | bigint | FK -> departments |
| created_at, updated_at | datetime | |

## specialties

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required, unique |
| created_at, updated_at | datetime | |

## subspecialties

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | |
| specialty_id | bigint | FK -> specialties |
| created_at, updated_at | datetime | |

## services

Medical service tags.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| name | string | required, unique |
| created_at, updated_at | datetime | |

## Join tables

### doctor_establishments

| Column | Type |
|---|---|
| id | bigint |
| doctor_profile_id | bigint, FK -> doctor_profiles |
| establishment_id | bigint, FK -> establishments |

### doctor_services

| Column | Type |
|---|---|
| id | bigint |
| doctor_profile_id | bigint, FK -> doctor_profiles |
| service_id | bigint, FK -> services |

Unique index on `(doctor_profile_id, service_id)`.

### establishment_services

| Column | Type |
|---|---|
| id | bigint |
| establishment_id | bigint, FK -> establishments |
| service_id | bigint, FK -> services |

Unique index on `(establishment_id, service_id)`.

### establishment_specialties

| Column | Type |
|---|---|
| id | bigint |
| establishment_id | bigint, FK -> establishments |
| specialty_id | bigint, FK -> specialties |

Unique index on `(establishment_id, specialty_id)`.

## Other tables

### articles

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| title | string | |
| content | text | |
| author_id | bigint | FK -> users |
| published_at | datetime | |

### notification_preferences

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| email_notifications | boolean | |
| marketing_emails | boolean | |
| new_features_notifications | boolean | |
| security_alerts | boolean | |

### payment_histories

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| amount | integer | |
| status | string | |
| payment_method | string | |
| description | text | |

### provider_profiles

Legacy table, not actively used by the current codebase.

| Column | Type |
|---|---|
| id | bigint |
| user_id | bigint, FK -> users |
| name, category, description, location, phone, website, image_url | string/text |

### roles / users_roles

Role-based tables (Rolify pattern). `users_roles` is a join table (no PK) with `user_id` and `role_id`.

### Active Storage tables

`active_storage_blobs`, `active_storage_attachments`, `active_storage_variant_records` -- standard Rails Active Storage tables. Present in the schema but image uploads primarily use `S3UploadService` with direct URL storage.

## Entity relationship summary

```
User 1--1 DoctorProfile
User 1--* Establishment
User 1--1 Supplier
User 1--1 Subscription --> SubscriptionPlan
User 1--* Session
User 1--1 NotificationPreference
User 1--* PaymentHistory

DoctorProfile *--* Establishment  (via doctor_establishments)
DoctorProfile *--* Service        (via doctor_services)
DoctorProfile *--1 Specialty
DoctorProfile *--1 Subspecialty
DoctorProfile *--1 Department
DoctorProfile *--1 City

Establishment *--* Specialty      (via establishment_specialties)
Establishment *--* Service        (via establishment_services)
Establishment *--1 Department
Establishment *--1 City

Supplier 1--* Product
Supplier 1--* LeadContact
Supplier *--1 Department
Supplier *--1 City

Department 1--* City
Specialty 1--* Subspecialty
```
