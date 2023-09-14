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

ActiveRecord::Schema[7.0].define(version: 2023_09_11_161839) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "client_reference_id"
    t.inet "remote_ip", null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.date "submission_date", null: false
    t.text "remarks"
    t.string "version"
    t.integer "level_of_help", default: 0, null: false
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

  create_table "eligibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_id", null: false
    t.string "type"
    t.string "proceeding_type_code", null: false
    t.decimal "lower_threshold"
    t.decimal "upper_threshold"
    t.string "assessment_result", default: "pending", null: false
    t.index ["parent_id", "type", "proceeding_type_code"], name: "eligibilities_unique_type_ptc", unique: true
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

  create_table "other_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "other_income_source_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.string "client_id"
    t.index ["other_income_source_id"], name: "index_other_income_payments_on_other_income_source_id"
  end

  create_table "other_income_sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "name", null: false
    t.decimal "monthly_income"
    t.index ["gross_income_summary_id"], name: "index_other_income_sources_on_gross_income_summary_id"
  end

  create_table "outgoings", force: :cascade do |t|
    t.uuid "disposable_income_summary_id", null: false
    t.string "type", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.string "housing_cost_type"
    t.string "client_id"
    t.index ["disposable_income_summary_id"], name: "index_outgoings_on_disposable_income_summary_id"
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

  create_table "regular_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "category"
    t.string "operation"
    t.decimal "amount"
    t.string "frequency"
    t.index ["gross_income_summary_id"], name: "index_regular_transactions_on_gross_income_summary_id"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "http_status", null: false
    t.decimal "duration", null: false
    t.jsonb "request", null: false
    t.jsonb "response", null: false
    t.date "created_at", null: false
    t.string "user_agent", null: false
  end

  create_table "state_benefit_payments", force: :cascade do |t|
    t.uuid "state_benefit_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.string "client_id"
    t.json "flags"
    t.index ["state_benefit_id"], name: "index_state_benefit_payments_on_state_benefit_id"
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

  create_table "state_benefits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.uuid "state_benefit_type_id", null: false
    t.string "name"
    t.index ["gross_income_summary_id"], name: "index_state_benefits_on_gross_income_summary_id"
    t.index ["state_benefit_type_id"], name: "index_state_benefits_on_state_benefit_type_id"
  end

  add_foreign_key "capital_summaries", "assessments"
  add_foreign_key "cash_transaction_categories", "gross_income_summaries"
  add_foreign_key "cash_transactions", "cash_transaction_categories"
  add_foreign_key "disposable_income_summaries", "assessments"
  add_foreign_key "gross_income_summaries", "assessments"
  add_foreign_key "irregular_income_payments", "gross_income_summaries"
  add_foreign_key "other_income_payments", "other_income_sources"
  add_foreign_key "other_income_sources", "gross_income_summaries"
  add_foreign_key "outgoings", "disposable_income_summaries"
  add_foreign_key "proceeding_types", "assessments"
  add_foreign_key "regular_transactions", "gross_income_summaries"
  add_foreign_key "state_benefit_payments", "state_benefits"
  add_foreign_key "state_benefits", "gross_income_summaries"
  add_foreign_key "state_benefits", "state_benefit_types"
end
