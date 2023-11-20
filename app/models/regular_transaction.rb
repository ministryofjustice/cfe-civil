class RegularTransaction
  include ActiveModel::Validations

  validates :category, :operation, :frequency, presence: true

  validates :operation, inclusion: { in: %i[credit debit],
                                     message: "%<value>s is not a valid operation" }

  attr_reader :frequency, :amount

  def initialize(category:, frequency:, operation:, amount:)
    @category = category
    @frequency = frequency
    @operation = operation
    @amount = amount
  end

  def pension_contribution?
    debit? && category == :pension_contribution
  end

  def council_tax_payment?
    debit? && category == :council_tax
  end

  def priority_debt_repayment?
    debit? && category == :priority_debt_repayment
  end

  def legal_aid_payment?
    debit? && category == :legal_aid
  end

  def maintenance_out_payment?
    debit? && category == :maintenance_out
  end

  def child_care_payment?
    debit? && category == :child_care
  end

  def rent_or_mortgage?
    debit? && category == :rent_or_mortgage
  end

  def benefit?
    credit? && category == :benefits
  end

  def maintenance_in?
    credit? && category == :maintenance_in
  end

  def housing_benefit?
    credit? && category == :housing_benefit
  end

  def friends_or_family?
    credit? && category == :friends_or_family
  end

  def property_or_lodger?
    credit? && category == :property_or_lodger
  end

  def pension?
    credit? && category == :pension
  end

  validates :category, inclusion: {
    in: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES.map(&:to_sym),
    message: "is not a valid credit category: %<value>s",
  }, if: :credit?

  validates :category, inclusion: {
    in: CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym),
    message: "is not a valid debit category: %<value>s",
  }, if: :debit?

  validates :frequency, inclusion: {
    in: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.map(&:to_s),
    message: "is not a valid frequency: %<value>s",
  }

private

  def credit?
    operation == :credit
  end

  def debit?
    operation == :debit
  end

  attr_reader :operation, :category
end
