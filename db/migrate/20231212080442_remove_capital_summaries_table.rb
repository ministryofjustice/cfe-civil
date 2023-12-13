class RemoveCapitalSummariesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :capital_summaries, id: :uuid do |t|
      t.uuid :assessment_id, index: true
      t.string :type, default: "ApplicantCapitalSummary"
    end
  end
end
