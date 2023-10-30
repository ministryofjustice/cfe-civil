class RegularTransaction < ApplicationRecord
  belongs_to :gross_income_summary

  validates :category, :operation, :frequency, presence: true

  validates :operation, inclusion: { in: %w[credit debit],
                                     message: "%<value>s is not a valid operation" }

  scope :pension_contributions, -> { where(category: "pension_contribution", operation: "debit") }
  scope :council_tax_payments, -> { where(category: "council_tax", operation: "debit") }

  validates :category, inclusion: {
    in: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES,
    message: "is not a valid credit category: %<value>s",
  }, if: :credit?

  validates :category, inclusion: {
    in: CFEConstants::VALID_OUTGOING_CATEGORIES,
    message: "is not a valid debit category: %<value>s",
  }, if: :debit?

  validates :frequency, inclusion: {
    in: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.map(&:to_s),
    message: "is not a valid frequency: %<value>s",
  }

  scope :with_operation_and_category, lambda { |operation, category|
    where(operation:, category:)
  }

  def credit?
    operation == "credit"
  end

  def debit?
    operation == "debit"
  end
end
