class UniquePartnerAndAssessmentIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :applicants, :assessment_id
    remove_index :partners, :assessment_id
    add_index :applicants, :assessment_id, unique: true
    add_index :partners, :assessment_id, unique: true
  end
end
