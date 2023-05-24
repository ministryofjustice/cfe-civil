class RemoveIncomeResults < ActiveRecord::Migration[7.0]
  def change
    remove_column :state_benefits, :monthly_value, :decimal, default: "0.0", null: false

    change_table :vehicles, bulk: true do |t|
      t.remove :included_in_assessment, type: :boolean, default: false, null: false
      t.remove :assessed_value, type: :decimal
    end

    change_table :employments, bulk: true do |t|
      t.remove :monthly_gross_income, type: :decimal, default: "0.0", null: false
      t.remove "monthly_benefits_in_kind", type: :decimal, default: "0.0", null: false
      t.remove "monthly_tax", type: :decimal, default: "0.0", null: false
      t.remove "monthly_national_insurance", type: :decimal, default: "0.0", null: false
      t.remove :calculation_method, type: :string
    end

    change_table :other_income_payments, bulk: true do |t|
      t.remove :assessment_error, type: :boolean, default: false
    end

    change_table :other_income_sources, bulk: true do |t|
      t.remove :assessment_error, type: :boolean, default: false
    end
  end
end
