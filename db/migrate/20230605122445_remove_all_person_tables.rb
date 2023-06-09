class RemoveAllPersonTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :dependants do |t|
      t.uuid "assessment_id"
      t.date "date_of_birth"
      t.boolean "in_full_time_education"
      t.string "relationship"
      t.decimal "monthly_income"
      t.decimal "assets_value"
      t.string "type", default: "ApplicantDependant"
    end
  end
end
