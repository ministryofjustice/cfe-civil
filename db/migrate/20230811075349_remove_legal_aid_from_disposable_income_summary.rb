class RemoveLegalAidFromDisposableIncomeSummary < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :legal_aid_cash, type: :decimal, default: 0.0
      t.remove :legal_aid_bank, type: :decimal, default: 0.0
      t.remove :legal_aid_all_sources, type: :decimal, default: 0.0
    end
  end
end
