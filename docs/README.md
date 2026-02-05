# Doctores Honduras

Healthcare directory for Honduras. Connects patients with doctors, hospitals, clinics, and medical suppliers across the country.

Built with Rails 8, PostgreSQL, Tailwind CSS, Stripe, and AWS S3.

## Documentation

- [Local Development Setup](setup.md) -- Ruby, Postgres, env vars, seeds, tests
- [Architecture](architecture.md) -- Models, controllers, services, auth system
- [Database Schema](database.md) -- All tables, columns, and relationships
- [Deployment](deployment.md) -- Railway + Docker, env vars, S3 bucket policy

## Key Concepts

**Profile types** -- Users register and choose one of: `doctor`, `hospital`, `clinic`, `vendor`, or viewer (no profile_type set). Each profile type has its own subscription tiers (gratis, profesional, elite/premium).

**Onboarding** -- Two-step flow after signup: pick a profile type, fill in basic info, then a free subscription plan is auto-assigned.

**Vendor system** -- Suppliers manage products and receive lead contacts. Free plan caps products at 5; leads require a paid plan.

**Stripe** -- Paid subscriptions go through Stripe Checkout. Webhooks keep local subscription state in sync.

**S3 uploads** -- Profile images are uploaded via `S3UploadService`. The bucket uses a bucket-level policy for public reads rather than per-object ACLs.

**Internationalization** -- Spanish (default) and English. Locale is resolved from session, user preference, params, or browser Accept-Language header.
