class RemoveHousingCostsColumnsFromDisposableIncomeSummaries < ActiveRecord::Migration[7.0]
  change_table :disposable_income_summaries, bulk: true do |t|
    t.remove "gross_housing_costs", type: :decimal, default: "0.0"
    t.remove "net_housing_costs", type: :decimal, default: "0.0"
    t.remove "housing_benefit", type: :decimal, default: "0.0"
  end
end
