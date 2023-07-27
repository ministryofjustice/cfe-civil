class RemoveRentOrMortgageFromDisposableIncomeSummary < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :rent_or_mortgage_cash, type: :decimal, default: 0.0
      t.remove :rent_or_mortgage_bank, type: :decimal, default: 0.0
      t.remove :rent_or_mortgage_all_sources, type: :decimal, default: 0.0
    end
  end
end
