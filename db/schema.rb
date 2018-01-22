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

ActiveRecord::Schema.define(version: 20170310200653) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.string "compatibility"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subject_id"
    t.index ["subject_id"], name: "index_configs_on_subject_id", unique: true
  end

  create_table "schema_versions", force: :cascade do |t|
    t.integer "version", default: 1
    t.bigint "subject_id", null: false
    t.bigint "schema_id", null: false
    t.index ["subject_id", "version"], name: "index_schema_versions_on_subject_id_and_version", unique: true
  end

  create_table "schemas", force: :cascade do |t|
    t.string "fingerprint", null: false
    t.text "json", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fingerprint2"
    t.index ["fingerprint"], name: "index_schemas_on_fingerprint"
    t.index ["fingerprint2"], name: "index_schemas_on_fingerprint2", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subjects_on_name", unique: true
  end

end
