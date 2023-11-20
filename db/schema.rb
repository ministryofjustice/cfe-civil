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

ActiveRecord::Schema[7.0].define(version: 2023_11_22_152733) do
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

  create_table "capital_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "type", default: "ApplicantCapitalSummary"
    t.index ["assessment_id"], name: "index_capital_summaries_on_assessment_id"
  end

  create_table "cash_transaction_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id"
    t.string "operation"
    t.string "name"
    t.index ["gross_income_summary_id", "name", "operation"], name: "index_cash_transaction_categories_uniqueness", unique: true
    t.index ["gross_income_summary_id"], name: "index_cash_transaction_categories_on_gross_income_summary_id"
  end

  create_table "cash_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cash_transaction_category_id"
    t.date "date"
    t.decimal "amount"
    t.string "client_id"
    t.index ["cash_transaction_category_id"], name: "index_cash_transactions_on_cash_transaction_category_id"
  end

  create_table "disposable_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.string "type", default: "ApplicantDisposableIncomeSummary"
    t.index ["assessment_id"], name: "index_disposable_income_summaries_on_assessment_id"
  end

  create_table "explicit_remarks", force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "category"
    t.string "remark"
  end

  create_table "gross_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "type", default: "ApplicantGrossIncomeSummary"
    t.index ["assessment_id"], name: "index_gross_income_summaries_on_assessment_id"
  end

  create_table "irregular_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "income_type", null: false
    t.string "frequency", null: false
    t.decimal "amount", default: "0.0"
    t.index ["gross_income_summary_id", "income_type"], name: "irregular_income_payments_unique", unique: true
    t.index ["gross_income_summary_id"], name: "index_irregular_income_payments_on_gross_income_summary_id"
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

  add_foreign_key "capital_summaries", "assessments"
  add_foreign_key "cash_transaction_categories", "gross_income_summaries"
  add_foreign_key "cash_transactions", "cash_transaction_categories"
  add_foreign_key "disposable_income_summaries", "assessments"
  add_foreign_key "gross_income_summaries", "assessments"
  add_foreign_key "irregular_income_payments", "gross_income_summaries"
  add_foreign_key "proceeding_types", "assessments"
end
