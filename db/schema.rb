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

ActiveRecord::Schema[7.2].define(version: 2017_03_10_200653) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.string "compatibility"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "fingerprint2"
    t.index ["fingerprint"], name: "index_schemas_on_fingerprint"
    t.index ["fingerprint2"], name: "index_schemas_on_fingerprint2", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_subjects_on_name", unique: true
  end
end
