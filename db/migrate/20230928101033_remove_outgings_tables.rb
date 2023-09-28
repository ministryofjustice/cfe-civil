class RemoveOutgingsTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :outgoings do |t|
      t.uuid "disposable_income_summary_id", null: false
      t.string "type", null: false
      t.date "payment_date", null: false
      t.decimal "amount", null: false
      t.string "housing_cost_type"
      t.string "client_id"
      t.index %w[disposable_income_summary_id], name: "index_outgoings_on_disposable_income_summary_id"
    end
  end
end
