class RemoveEmploymentsAndEmploymentPaymentsTables < ActiveRecord::Migration[7.0]
  def change
    drop_table "employment_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references "employment", foreign_key: true, type: :uuid
      t.date "date", null: false
      t.decimal "gross_income", default: "0.0", null: false
      t.decimal "benefits_in_kind", default: "0.0", null: false
      t.decimal "tax", default: "0.0", null: false
      t.decimal "national_insurance", default: "0.0", null: false
      t.string "client_id", null: false
    end

    drop_table "employments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references "assessment", foreign_key: true, type: :uuid
      t.string "name"
      t.string "client_id", null: false
      t.string "type", default: "ApplicantEmployment"
      t.boolean "receiving_only_statutory_sick_or_maternity_pay", default: false
    end
  end
end
