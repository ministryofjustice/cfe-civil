class RemoveIrregularTransactions < ActiveRecord::Migration[7.0]
  def change
    drop_table :irregular_income_payments, id: :uuid do |t|
      t.uuid :gross_income_summary_id, null: false
      t.string :income_type, null: false
      t.string :frequency, null: false
      t.decimal :amount, default: "0.0"
      t.index %i[gross_income_summary_id income_type], name: "irregular_income_payments_unique", unique: true
      t.index :gross_income_summary_id
    end
  end
end
