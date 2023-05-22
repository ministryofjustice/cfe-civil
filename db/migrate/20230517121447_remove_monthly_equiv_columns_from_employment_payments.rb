class RemoveMonthlyEquivColumnsFromEmploymentPayments < ActiveRecord::Migration[7.0]
  def change
    change_table :employment_payments, bulk: true do |t|
      t.remove(
        :gross_income_monthly_equiv,
        :tax_monthly_equiv,
        :national_insurance_monthly_equiv, type: :decimal, null: false, default: 0.0
      )
    end
  end
end
