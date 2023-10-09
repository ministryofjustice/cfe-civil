class RemoveColumnAssessmentResultFromAssessments < ActiveRecord::Migration[7.0]
  def change
    remove_column :assessments, :assessment_result, :string, default: "pending", null: false
  end
end
