class DeleteGrossAndDisposableSummaryTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :disposable_income_summaries, id: :uuid do |t|
      t.uuid "assessment_id", null: false
      t.string "type", default: "ApplicantDisposableIncomeSummary"
      t.index %w[assessment_id], name: "index_disposable_income_summaries_on_assessment_id"
    end

    drop_table :gross_income_summaries, id: :uuid do |t|
      t.uuid "assessment_id"
      t.string "type", default: "ApplicantGrossIncomeSummary"
      t.index %w[assessment_id], name: "index_gross_income_summaries_on_assessment_id"
    end
  end
end
