# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170226173737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "distributions", force: :cascade do |t|
    t.string   "name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "recurrence"
    t.index ["organization_id"], name: "index_distributions_on_organization_id", using: :btree
  end

  create_table "lines", force: :cascade do |t|
    t.string   "name"
    t.string   "text_color"
    t.string   "background_color"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.boolean  "sent_by_user"
    t.integer  "recipient_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["recipient_id"], name: "index_messages_on_recipient_id", using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "recipients", force: :cascade do |t|
    t.string   "phone_number"
    t.boolean  "subscribed",   default: false
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "organization_id"
    t.boolean  "admin"

    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["organization_id"], name: "index_users_on_organization_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "messages", "recipients"
    t.index ["email"], name: "index_organizations_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_organizations_on_reset_password_token", unique: true, using: :btree
  end

  create_table "stations", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stops", force: :cascade do |t|
    t.integer  "station_id"
    t.integer  "line_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_id"], name: "index_stops_on_line_id", using: :btree
    t.index ["station_id"], name: "index_stops_on_station_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "phone_number"
    t.boolean  "subscribed",   default: false
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_foreign_key "distributions", "organizations"
  add_foreign_key "messages", "users"
  add_foreign_key "stops", "lines"
  add_foreign_key "stops", "stations"
end
