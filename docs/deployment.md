# Deployment

The app deploys on **Railway** using a Docker-based build.

## Docker build

The `Dockerfile` uses a multi-stage build:

1. **base** -- Ruby 3.3.0-slim with system libs (libvips, postgresql-client, jemalloc)
2. **build** -- Installs build tools, runs `bundle install`, precompiles bootsnap and assets (`SECRET_KEY_BASE_DUMMY=1` so no real key is needed at build time)
3. **final** -- Copies gems and app from build stage, runs as non-root `rails` user (UID 1000)

The entrypoint is `bin/docker-entrypoint`, which:
- Enables jemalloc for reduced memory usage
- Runs `bin/rails db:prepare` before starting the server (creates or migrates the database)
- Logs AWS env var status for debugging

The server runs via Thruster (`bin/thrust`) on port 80.

## Railway configuration

1. Connect the GitHub repository to a Railway project.
2. Railway auto-detects the Dockerfile and builds from it.
3. Set all required environment variables in the Railway dashboard (see below).
4. The database is typically a Railway-managed PostgreSQL add-on. Railway sets `DATABASE_URL` automatically when you link the DB service to the app.

## Required environment variables

Set these in Railway (or any hosting platform):

| Variable | Value |
|---|---|
| `DATABASE_URL` | `postgres://user:pass@host:port/dbname` (auto-set by Railway Postgres add-on) |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` |
| `SECRET_KEY_BASE` | Generated via `bin/rails secret` (or use RAILS_MASTER_KEY + credentials) |
| `RAILS_ENV` | `production` |
| `STRIPE_PUBLISHABLE_KEY` | `pk_live_...` or `pk_test_...` |
| `STRIPE_SECRET_KEY` | `sk_live_...` or `sk_test_...` |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` (from Stripe dashboard webhook settings) |
| `AWS_BUCKET` | S3 bucket name |
| `AWS_REGION` | e.g. `us-east-1` |
| `AWS_ACCESS_KEY_ID` | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key |

## S3 bucket policy

The app uses a **bucket policy** for public reads instead of per-object ACLs. This avoids needing `public-read` ACLs on each upload (which newer S3 buckets block by default).

Apply this policy to the S3 bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```

Replace `YOUR_BUCKET_NAME` with your actual bucket name.

The IAM user (whose keys are in `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) needs `s3:PutObject` permission on the bucket.

## Database migrations on deploy

`db:prepare` runs automatically in `bin/docker-entrypoint` before the server starts. It will:
- Create the database if it does not exist
- Run pending migrations if the database already exists

No manual migration step is needed.

## Stripe webhook setup

1. In the Stripe dashboard, create a webhook endpoint pointing to `https://your-domain.com/stripe/webhook`.
2. Subscribe to these events: `checkout.session.completed`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.deleted`, `customer.subscription.updated`.
3. Copy the webhook signing secret to the `STRIPE_WEBHOOK_SECRET` env var.

## Health check

`GET /up` returns 200 if the app is healthy. Use this for Railway health checks or uptime monitoring.
