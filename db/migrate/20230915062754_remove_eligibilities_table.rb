class RemoveEligibilitiesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table "eligibilities", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid "parent_id", null: false
      t.string "type"
      t.string "proceeding_type_code", null: false
      t.decimal "lower_threshold"
      t.decimal "upper_threshold"
      t.string "assessment_result", default: "pending", null: false
      t.index %w[parent_id type proceeding_type_code], name: "eligibilities_unique_type_ptc", unique: true
    end
  end
end
