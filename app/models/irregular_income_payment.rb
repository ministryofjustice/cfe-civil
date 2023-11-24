class IrregularIncomePayment
  include ActiveModel::Validations

  attr_reader :frequency, :amount

  def initialize(income_type:, frequency:, amount:)
    @income_type = income_type
    @frequency = frequency
    @amount = amount
  end

  validates :income_type, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.map(&:to_sym) }
  validates :frequency, inclusion: { in: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def student_loan_payment?
    income_type == CFEConstants::STUDENT_LOAN.to_sym
  end

  def unspecified_source_payment?
    income_type == CFEConstants::UNSPECIFIED_SOURCE.to_sym
  end

private

  attr_reader :income_type
end
