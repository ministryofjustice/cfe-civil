class RemovePropertiesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :properties, id: :uuid do |t|
      t.decimal "value"
      t.decimal "outstanding_mortgage"
      t.decimal "percentage_owned"
      t.boolean "main_home"
      t.boolean "shared_with_housing_assoc"
      t.boolean "subject_matter_of_dispute"
      t.references "capital_summary", foreign_key: true, type: :uuid
    end
  end
end
