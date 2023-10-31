class CashTransaction < ApplicationRecord
  belongs_to :cash_transaction_category

  scope :by_operation_and_category, lambda { |operation, category_name|
    joins(:cash_transaction_category)
      .where(cash_transaction_category: { name: category_name, operation: })
      .order(:date)
  }
end
