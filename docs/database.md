# Database Schema

PostgreSQL database. Schema version: `2026_02_16_090002`.

## users

Primary table for all accounts.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| email | string | unique index, normalized (strip + downcase) |
| password_digest | string | bcrypt hash |
| profile_type | string | `doctor`, `hospital`, `clinic`, `vendor`, `paciente`, or NULL (viewer) |
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

## patient_profiles

Patient accounts linked to users with profile_type = "paciente".

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users, unique |
| name | string | required |
| phone | string | |
| date_of_birth | date | |
| department_id | bigint | FK -> departments |
| city_id | bigint | FK -> cities |
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
| profile_type | string | `doctor`, `hospital`, `vendor`, `paciente` |
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

## Agenda System

### secretary_assignments

Vincula un User (secretaria) con un DoctorProfile.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| doctor_profile_id | bigint | FK -> doctor_profiles |
| status | string | `active` (default), `revoked` |
| invitation_token | string | unique index |
| invitation_accepted_at | datetime | |
| invited_email | string | |
| created_at, updated_at | datetime | |

Unique index on `(user_id, doctor_profile_id)`.

### doctor_agenda_settings

Configuracion de agenda por doctor. One per DoctorProfile.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| doctor_profile_id | bigint | FK -> doctor_profiles, unique |
| appointment_duration | integer | default 30 (15, 20, 30, 45, 60) |
| buffer_minutes | integer | default 0 (0-30) |
| public_booking_enabled | boolean | default false, requires elite tier |
| created_at, updated_at | datetime | |

### appointments

Citas medicas.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| doctor_profile_id | bigint | FK -> doctor_profiles |
| doctor_branch_id | bigint | FK -> doctor_branches |
| patient_name | string | required |
| patient_phone | string | |
| patient_email | string | indexed |
| appointment_date | date | required |
| start_time | time | required |
| end_time | time | required |
| status | string | `pendiente` (default), `confirmada`, `cancelada`, `completada` |
| reason | text | |
| doctor_notes | text | |
| booking_source | string | `manual` (default), `public_booking` |
| created_by_id | bigint | FK -> users, optional |
| patient_user_id | bigint | FK -> users, optional (links to patient account) |
| created_at, updated_at | datetime | |

Indices: `(doctor_branch_id, appointment_date, start_time)`, `(doctor_profile_id, appointment_date)`, `status`, `patient_email`, `patient_user_id`.

Custom validations: `within_branch_schedule` (appointment times must be within branch operating hours), `no_overlapping_appointments` (no two active appointments can overlap on same branch/date).

### appointment_notifications

Notificaciones in-app para citas.

| Column | Type | Notes |
|---|---|---|
| id | bigint | PK |
| user_id | bigint | FK -> users |
| appointment_id | bigint | FK -> appointments |
| notification_type | string | `nueva_cita`, `cambio_estado` |
| message | text | |
| read | boolean | default false |
| read_at | datetime | |
| created_at, updated_at | datetime | |

Index on `(user_id, read)`.

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
User 1--1 PatientProfile
User 1--1 Subscription --> SubscriptionPlan
User 1--* Session
User 1--1 NotificationPreference
User 1--* PaymentHistory
User 1--* SecretaryAssignment
User 1--* AppointmentNotification
User 1--* Appointment (as patient_user)

DoctorProfile *--* Establishment  (via doctor_establishments)
DoctorProfile *--* Service        (via doctor_services)
DoctorProfile *--1 Specialty
DoctorProfile *--1 Subspecialty
DoctorProfile *--1 Department
DoctorProfile *--1 City
DoctorProfile 1--* SecretaryAssignment
DoctorProfile 1--1 DoctorAgendaSetting
DoctorProfile 1--* Appointment
DoctorProfile 1--* DoctorBranch

DoctorBranch 1--* BranchSchedule
DoctorBranch 1--* Appointment

Appointment 1--* AppointmentNotification

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
