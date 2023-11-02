class CashTransaction < ApplicationRecord
  belongs_to :cash_transaction_category

  scope :by_operation_and_category, lambda { |operation, category_name|
    joins(:cash_transaction_category)
      .where(cash_transaction_category: { name: category_name, operation: })
      .order(:date)
  }

  scope :pension_contributions, -> { by_operation_and_category(:debit, :pension_contribution) }
  scope :council_tax_payments, -> { by_operation_and_category(:debit, :council_tax) }
  scope :priority_debt_repayments, -> { by_operation_and_category(:debit, :priority_debt_repayment) }
end
