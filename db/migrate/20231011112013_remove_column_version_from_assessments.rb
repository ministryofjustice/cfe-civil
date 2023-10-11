class RemoveColumnVersionFromAssessments < ActiveRecord::Migration[7.0]
  def change
    remove_column :assessments, :version, :string
  end
end
