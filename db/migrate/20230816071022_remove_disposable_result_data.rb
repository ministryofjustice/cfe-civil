class RemoveDisposableResultData < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove "lower_threshold", type: :decimal, default: "0.0", null: false
      t.remove "upper_threshold", type: :decimal, default: "0.0", null: false
      t.remove "income_contribution", type: :decimal, default: "0.0"
      t.remove "assessment_result", type: :string, default: "pending", null: false
    end
  end
end
