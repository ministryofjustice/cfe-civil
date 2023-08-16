class RemoveMaintenanceOutColumnsFromFromDisposableIncomeSummary < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :maintenance_out_cash, type: :decimal, default: 0.0
      t.remove :maintenance_out_bank, type: :decimal, default: 0.0
      t.remove :maintenance_out_all_sources, type: :decimal, default: 0.0
    end
  end
end
