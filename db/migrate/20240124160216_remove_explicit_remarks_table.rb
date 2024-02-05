class RemoveExplicitRemarksTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :explicit_remarks do |t|
      t.uuid "assessment_id"
      t.string "category"
      t.string "remark"
    end
  end
end
