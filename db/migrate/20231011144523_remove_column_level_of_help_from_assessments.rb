class RemoveColumnLevelOfHelpFromAssessments < ActiveRecord::Migration[7.0]
  def change
    remove_column :assessments, :level_of_help, :integer, default: 0, null: false
  end
end
