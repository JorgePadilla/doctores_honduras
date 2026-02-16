# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_16_090002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointment_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "appointment_id", null: false
    t.string "notification_type", null: false
    t.text "message", null: false
    t.boolean "read", default: false, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_notifications_on_appointment_id"
    t.index ["user_id", "read"], name: "index_appointment_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_appointment_notifications_on_user_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.bigint "doctor_branch_id", null: false
    t.string "patient_name", null: false
    t.string "patient_phone"
    t.string "patient_email"
    t.date "appointment_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.string "status", default: "pendiente", null: false
    t.text "reason"
    t.text "doctor_notes"
    t.string "booking_source", default: "manual", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_user_id"
    t.index ["created_by_id"], name: "index_appointments_on_created_by_id"
    t.index ["doctor_branch_id", "appointment_date", "start_time"], name: "idx_appointments_branch_date_time"
    t.index ["doctor_branch_id"], name: "index_appointments_on_doctor_branch_id"
    t.index ["doctor_profile_id", "appointment_date"], name: "idx_appointments_doctor_date"
    t.index ["doctor_profile_id"], name: "index_appointments_on_doctor_profile_id"
    t.index ["patient_email"], name: "index_appointments_on_patient_email"
    t.index ["patient_user_id"], name: "index_appointments_on_patient_user_id"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "author_id", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
  end

  create_table "branch_schedules", force: :cascade do |t|
    t.bigint "doctor_branch_id", null: false
    t.integer "day_of_week", null: false
    t.time "opens_at", null: false
    t.time "closes_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_branch_id", "day_of_week"], name: "index_branch_schedules_on_doctor_branch_id_and_day_of_week", unique: true
    t.index ["doctor_branch_id"], name: "index_branch_schedules_on_doctor_branch_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_cities_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "doctor_agenda_settings", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.integer "appointment_duration", default: 30, null: false
    t.integer "buffer_minutes", default: 0, null: false
    t.boolean "public_booking_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id"], name: "index_doctor_agenda_settings_on_doctor_profile_id", unique: true
  end

  create_table "doctor_branches", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.string "name", null: false
    t.string "address", null: false
    t.bigint "department_id"
    t.bigint "city_id"
    t.string "map_link"
    t.string "phone"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_doctor_branches_on_city_id"
    t.index ["department_id"], name: "index_doctor_branches_on_department_id"
    t.index ["doctor_profile_id"], name: "index_doctor_branches_on_doctor_profile_id"
  end

  create_table "doctor_certifications", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.string "name", null: false
    t.string "institution"
    t.integer "year"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id"], name: "index_doctor_certifications_on_doctor_profile_id"
  end

  create_table "doctor_educations", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.string "institution", null: false
    t.string "degree"
    t.integer "graduation_year"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id"], name: "index_doctor_educations_on_doctor_profile_id"
  end

  create_table "doctor_establishments", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id"], name: "index_doctor_establishments_on_doctor_profile_id"
    t.index ["establishment_id"], name: "index_doctor_establishments_on_establishment_id"
  end

  create_table "doctor_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.string "website"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "medical_license"
    t.string "state"
    t.string "subspecialty"
    t.boolean "hidden", default: false, null: false
    t.bigint "specialty_id"
    t.bigint "subspecialty_id"
    t.bigint "department_id"
    t.bigint "city_id"
    t.string "video_consultation_url"
    t.date "fecha_de_nacimiento"
    t.string "numero_de_identidad"
    t.string "correo_personal"
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "twitter_url"
    t.string "linkedin_url"
    t.string "tiktok_url"
    t.string "youtube_url"
    t.text "languages", default: [], array: true
    t.index ["city_id"], name: "index_doctor_profiles_on_city_id"
    t.index ["department_id"], name: "index_doctor_profiles_on_department_id"
    t.index ["specialty_id"], name: "index_doctor_profiles_on_specialty_id"
    t.index ["subspecialty_id"], name: "index_doctor_profiles_on_subspecialty_id"
    t.index ["user_id"], name: "index_doctor_profiles_on_user_id"
  end

  create_table "doctor_services", force: :cascade do |t|
    t.bigint "doctor_profile_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id", "service_id"], name: "idx_unique_doctor_service", unique: true
    t.index ["doctor_profile_id"], name: "index_doctor_services_on_doctor_profile_id"
    t.index ["service_id"], name: "index_doctor_services_on_service_id"
  end

  create_table "establishment_services", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id", "service_id"], name: "idx_unique_establishment_service", unique: true
    t.index ["establishment_id"], name: "index_establishment_services_on_establishment_id"
    t.index ["service_id"], name: "index_establishment_services_on_service_id"
  end

  create_table "establishment_specialties", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "specialty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id", "specialty_id"], name: "idx_unique_establishment_specialty", unique: true
    t.index ["establishment_id"], name: "index_establishment_specialties_on_establishment_id"
    t.index ["specialty_id"], name: "index_establishment_specialties_on_specialty_id"
  end

  create_table "establishments", force: :cascade do |t|
    t.string "name"
    t.string "est_type"
    t.string "address"
    t.string "phone"
    t.string "map_link"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_url"
    t.string "building_image_url"
    t.bigint "user_id"
    t.bigint "department_id"
    t.bigint "city_id"
    t.text "description"
    t.string "website"
    t.string "email"
    t.index ["user_id"], name: "index_establishments_on_user_id"
  end

  create_table "lead_contacts", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "organization"
    t.text "message"
    t.string "status", default: "new"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_lead_contacts_on_supplier_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "email_notifications"
    t.boolean "marketing_emails"
    t.boolean "new_features_notifications"
    t.boolean "security_alerts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.date "date_of_birth"
    t.bigint "department_id"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_patient_profiles_on_city_id"
    t.index ["department_id"], name: "index_patient_profiles_on_department_id"
    t.index ["user_id"], name: "index_patient_profiles_on_user_id", unique: true
  end

  create_table "payment_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount"
    t.string "status"
    t.string "payment_method"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payment_histories_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.text "description"
    t.decimal "price"
    t.string "category"
    t.string "image_url"
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.boolean "featured", default: false
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "profile_views", force: :cascade do |t|
    t.string "viewable_type", null: false
    t.bigint "viewable_id", null: false
    t.bigint "viewer_id"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address", "viewable_type", "viewable_id", "created_at"], name: "idx_profile_views_dedup"
    t.index ["viewable_type", "viewable_id", "created_at"], name: "idx_on_viewable_type_viewable_id_created_at_d7cb744234"
    t.index ["viewable_type", "viewable_id"], name: "index_profile_views_on_viewable_type_and_viewable_id"
    t.index ["viewer_id"], name: "index_profile_views_on_viewer_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "category"
    t.text "description"
    t.string "location"
    t.string "phone"
    t.string "website"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "secretary_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "doctor_profile_id", null: false
    t.string "status", default: "active", null: false
    t.string "invitation_token"
    t.datetime "invitation_accepted_at"
    t.string "invited_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id"], name: "index_secretary_assignments_on_doctor_profile_id"
    t.index ["invitation_token"], name: "index_secretary_assignments_on_invitation_token", unique: true
    t.index ["user_id", "doctor_profile_id"], name: "index_secretary_assignments_on_user_id_and_doctor_profile_id", unique: true
    t.index ["user_id"], name: "index_secretary_assignments_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "specialty_id"
    t.index ["specialty_id"], name: "index_services_on_specialty_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "price"
    t.string "interval"
    t.text "features"
    t.string "stripe_price_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_product_id"
    t.boolean "visible"
    t.string "profile_type"
    t.string "tier"
    t.integer "position", default: 0
    t.index ["profile_type", "tier"], name: "index_subscription_plans_on_profile_type_and_tier", unique: true
    t.index ["stripe_price_id"], name: "index_subscription_plans_on_stripe_price_id", unique: true
    t.index ["stripe_product_id"], name: "index_subscription_plans_on_stripe_product_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan"
    t.string "status"
    t.string "stripe_subscription_id"
    t.datetime "next_billing_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subscription_plan_id"
    t.string "plan_name"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "cancel_at"
    t.string "stripe_customer_id"
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "subspecialties", force: :cascade do |t|
    t.string "name"
    t.bigint "specialty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["specialty_id"], name: "index_subspecialties_on_specialty_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.text "description"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "category"
    t.string "website"
    t.bigint "department_id"
    t.bigint "city_id"
    t.boolean "featured", default: false
    t.boolean "hidden", default: false
    t.index ["user_id"], name: "index_suppliers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.string "two_factor_secret"
    t.string "profile_type"
    t.boolean "onboarding_completed"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointment_notifications", "appointments"
  add_foreign_key "appointment_notifications", "users"
  add_foreign_key "appointments", "doctor_branches"
  add_foreign_key "appointments", "doctor_profiles"
  add_foreign_key "appointments", "users", column: "created_by_id"
  add_foreign_key "appointments", "users", column: "patient_user_id"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "branch_schedules", "doctor_branches"
  add_foreign_key "cities", "departments"
  add_foreign_key "doctor_agenda_settings", "doctor_profiles"
  add_foreign_key "doctor_branches", "cities"
  add_foreign_key "doctor_branches", "departments"
  add_foreign_key "doctor_branches", "doctor_profiles"
  add_foreign_key "doctor_certifications", "doctor_profiles"
  add_foreign_key "doctor_educations", "doctor_profiles"
  add_foreign_key "doctor_establishments", "doctor_profiles"
  add_foreign_key "doctor_establishments", "establishments"
  add_foreign_key "doctor_profiles", "cities"
  add_foreign_key "doctor_profiles", "departments"
  add_foreign_key "doctor_profiles", "specialties"
  add_foreign_key "doctor_profiles", "subspecialties"
  add_foreign_key "doctor_profiles", "users"
  add_foreign_key "doctor_services", "doctor_profiles"
  add_foreign_key "doctor_services", "services"
  add_foreign_key "establishment_services", "establishments"
  add_foreign_key "establishment_services", "services"
  add_foreign_key "establishment_specialties", "establishments"
  add_foreign_key "establishment_specialties", "specialties"
  add_foreign_key "establishments", "users"
  add_foreign_key "lead_contacts", "suppliers"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "patient_profiles", "cities"
  add_foreign_key "patient_profiles", "departments"
  add_foreign_key "patient_profiles", "users"
  add_foreign_key "payment_histories", "users"
  add_foreign_key "products", "suppliers"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "secretary_assignments", "doctor_profiles"
  add_foreign_key "secretary_assignments", "users"
  add_foreign_key "services", "specialties"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "subspecialties", "specialties"
  add_foreign_key "suppliers", "users"
end
