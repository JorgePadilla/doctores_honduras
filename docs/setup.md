# Local Development Setup

## Prerequisites

- Ruby 3.3.0 (see `.ruby-version`)
- PostgreSQL 14+
- Node.js (for Tailwind CSS build via `tailwindcss-rails`)
- Git

## 1. Clone and install dependencies

```bash
git clone <repo-url> && cd doctores_honduras
bundle install
```

## 2. Database setup

Rails uses PostgreSQL. The development database name is `doctores_honduras_development`.

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Seeds create: departments, cities, specialties, services, subscription plans (per-profile-type tiers), sample doctors, establishments, suppliers, and products.

## 3. Environment variables

Create a `.env` file or export these in your shell. None are required for basic local development, but features will be limited without them.

| Variable | Purpose | Required locally? |
|---|---|---|
| `DATABASE_URL` | Postgres connection string (production only; dev uses `database.yml`) | No |
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` | Only if using credentials |
| `STRIPE_PUBLISHABLE_KEY` | Stripe public key for checkout | For payments |
| `STRIPE_SECRET_KEY` | Stripe secret key | For payments |
| `STRIPE_WEBHOOK_SECRET` | Verifies Stripe webhook signatures | For webhooks |
| `AWS_BUCKET` | S3 bucket name | For image uploads |
| `AWS_REGION` | S3 region (defaults to `us-east-1`) | For image uploads |
| `AWS_ACCESS_KEY_ID` | AWS IAM access key | For image uploads |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key | For image uploads |

## 4. Run the app

```bash
bin/dev
```

This starts Puma and the Tailwind CSS watcher via `Procfile.dev`.

The app runs at `http://localhost:3000`.

## 5. Running tests

```bash
bin/rails test          # unit and integration tests
bin/rails test:system   # system tests (Capybara + Selenium)
```

## 6. Code quality

```bash
bundle exec rubocop     # Ruby style checks (rubocop-rails-omakase)
bundle exec brakeman    # Security static analysis
```

## Notes

- Tailwind CSS is managed by the `tailwindcss-rails` gem (v4.2). No separate Node-based build is needed for styles.
- The asset pipeline uses Propshaft, not Sprockets.
- JS is served via import maps (`importmap-rails`), not a JS bundler.
- Hotwire (Turbo + Stimulus) handles SPA-like interactions.
