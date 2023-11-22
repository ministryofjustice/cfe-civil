class RemoveTablesOtherIncomePaymentsAndOtherIncomeSources < ActiveRecord::Migration[7.0]
  def change
    drop_table "other_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references "other_income_source", foreign_key: true, type: :uuid, null: false
      t.date "payment_date", null: false
      t.decimal "amount", null: false
      t.string "client_id"
    end

    drop_table "other_income_sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references "gross_income_summary", foreign_key: true, type: :uuid, null: false
      t.string "name", null: false
      t.decimal "monthly_income"
    end
  end
end
