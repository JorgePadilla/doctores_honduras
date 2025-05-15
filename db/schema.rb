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

ActiveRecord::Schema[8.0].define(version: 2025_05_15_092637) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "author_id", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
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
    t.string "specialization"
    t.text "description"
    t.string "location"
    t.string "website"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_doctor_profiles_on_user_id"
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

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan"
    t.string "status"
    t.string "stripe_subscription_id"
    t.datetime "next_billing_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "doctor_establishments", "doctor_profiles"
  add_foreign_key "doctor_establishments", "establishments"
  add_foreign_key "doctor_profiles", "users"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriptions", "users"
end
