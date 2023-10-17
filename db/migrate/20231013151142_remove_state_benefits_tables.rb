class RemoveStateBenefitsTables < ActiveRecord::Migration[7.0]
  def change
    drop_table "state_benefit_payments" do |t|
      t.uuid "state_benefit_id", null: false
      t.date "payment_date", null: false
      t.decimal "amount", null: false
      t.string "client_id"
      t.json "flags"
      t.index %w[state_benefit_id], name: "index_state_benefit_payments_on_state_benefit_id"
    end

    drop_table "state_benefits", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid "gross_income_summary_id", null: false
      t.uuid "state_benefit_type_id", null: false
      t.string "name"
      t.index %w[gross_income_summary_id], name: "index_state_benefits_on_gross_income_summary_id"
      t.index %w[state_benefit_type_id], name: "index_state_benefits_on_state_benefit_type_id"
    end
  end
end
