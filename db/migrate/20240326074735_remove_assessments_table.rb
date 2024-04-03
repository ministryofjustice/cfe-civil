class RemoveAssessmentsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table "assessments", id: :uuid do |t|
      t.string "client_reference_id"
      t.inet "remote_ip", null: false
      t.date "created_at", null: false
      t.date "updated_at", null: false
      t.date "submission_date", null: false
      t.index %w[client_reference_id]
    end
  end
end
