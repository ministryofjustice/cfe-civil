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

ActiveRecord::Schema[7.1].define(version: 2024_01_12_153939) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "client_reference_id"
    t.inet "remote_ip", null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.date "submission_date", null: false
    t.index ["client_reference_id"], name: "index_assessments_on_client_reference_id"
  end

  create_table "explicit_remarks", force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "category"
    t.string "remark"
  end

  create_table "proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "ccms_code", null: false
    t.string "client_involvement_type"
    t.decimal "gross_income_upper_threshold"
    t.decimal "disposable_income_upper_threshold"
    t.decimal "capital_upper_threshold"
    t.index ["assessment_id", "ccms_code"], name: "index_proceeding_types_on_assessment_id_and_ccms_code", unique: true
    t.index ["assessment_id"], name: "index_proceeding_types_on_assessment_id"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "http_status", null: false
    t.decimal "duration", null: false
    t.jsonb "request", null: false
    t.jsonb "response", null: false
    t.date "created_at", null: false
    t.string "user_agent", null: false
  end

  create_table "state_benefit_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.text "name"
    t.boolean "exclude_from_gross_income"
    t.string "dwp_code"
    t.string "category"
    t.index ["dwp_code"], name: "index_state_benefit_types_on_dwp_code", unique: true
    t.index ["label"], name: "index_state_benefit_types_on_label", unique: true
  end

  add_foreign_key "proceeding_types", "assessments"
end
