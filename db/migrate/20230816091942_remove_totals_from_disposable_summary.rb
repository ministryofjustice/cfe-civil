class RemoveTotalsFromDisposableSummary < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :total_outgoings_and_allowances, type: :decimal, default: 0.0, null: false
      t.remove :total_disposable_income, type: :decimal, default: 0.0, null: false

      t.remove :combined_total_disposable_income, type: :decimal
      t.remove :combined_total_outgoings_and_allowances, type: :decimal
    end
  end
end
