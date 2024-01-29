class RemoveProceedingTypesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :proceeding_types, id: :uuid do |t|
      t.uuid :assessment_id, index: true
      t.string "ccms_code", null: false
      t.string "client_involvement_type"
      t.decimal "gross_income_upper_threshold"
      t.decimal "disposable_income_upper_threshold"
      t.decimal "capital_upper_threshold"
      t.index %i[assessment_id ccms_code], unique: true
    end
  end
end
