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

ActiveRecord::Schema[7.1].define(version: 2025_02_17_190652) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "location", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "total_tickets", null: false
    t.integer "available_tickets", null: false
    t.integer "ticket_price_cents", null: false
    t.string "currency", null: false
    t.float "rate"
    t.integer "created_by", null: false
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_events_on_created_by"
    t.index ["end_time"], name: "index_events_on_end_time"
    t.index ["start_time"], name: "index_events_on_start_time"
    t.index ["state"], name: "index_events_on_state"
    t.index ["ticket_price_cents"], name: "index_events_on_ticket_price_cents"
    t.check_constraint "available_tickets <= total_tickets", name: "available_tickets_check"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.integer "price_cents", null: false
    t.string "currency", null: false
    t.string "state", default: "pending", null: false
    t.datetime "booked_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "state"], name: "index_tickets_on_event_id_and_state"
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["price_cents"], name: "index_tickets_on_price_cents"
    t.index ["state"], name: "index_tickets_on_state"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "role_id", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "users"
  add_foreign_key "users", "roles"
end
