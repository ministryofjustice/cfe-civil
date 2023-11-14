class RemoveColumnRemarksFromAssessments < ActiveRecord::Migration[7.0]
  def change
    remove_column :assessments, :remarks, :text
  end
end
