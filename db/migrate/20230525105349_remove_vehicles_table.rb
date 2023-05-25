class RemoveVehiclesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :vehicles do |t|
      t.decimal :value
      t.decimal :loan_amount_outstanding
      t.date :date_of_purchase
      t.boolean :in_regular_use
      t.uuid :capital_summary_id, index: true
      t.boolean :subject_matter_of_dispute
    end
  end
end
