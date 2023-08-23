class RemoveCapitalItemsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :capital_items, id: :uuid do
      t.uuid "capital_summary_id"
      t.string "type", null: false
      t.string "description", null: false
      t.decimal "value", default: "0.0", null: false
      t.boolean "subject_matter_of_dispute"
      t.index %w[capital_summary_id], name: "index_capital_items_on_capital_summary_id"
    end
  end
end
