class RemoveCashTransactionsTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :cash_transactions, id: :uuid do |t|
      t.uuid :cash_transaction_category_id
      t.date :date
      t.decimal :amount
      t.string :client_id
      t.index :cash_transaction_category_id
    end

    drop_table :cash_transaction_categories, id: :uuid do |t|
      t.uuid :gross_income_summary_id
      t.string :operation
      t.string :name
      t.index %w[gross_income_summary_id name operation], unique: true
      t.index :gross_income_summary_id
    end
  end
end
