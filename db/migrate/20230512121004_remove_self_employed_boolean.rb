class RemoveSelfEmployedBoolean < ActiveRecord::Migration[7.0]
  def change
    remove_column :applicants, :self_employed, :boolean, default: false
  end
end
