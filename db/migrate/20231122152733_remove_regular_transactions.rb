class RemoveRegularTransactions < ActiveRecord::Migration[7.0]
  def change
    drop_table "regular_transactions", id: :uuid do |t|
      t.uuid :gross_income_summary_id, null: false
      t.string :category
      t.string :operation
      t.decimal :amount
      t.string :frequency
      t.index :gross_income_summary_id
    end
  end
end
