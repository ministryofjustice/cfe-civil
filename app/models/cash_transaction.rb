class CashTransaction
  include ActiveModel::Validations
  attr_reader :date, :amount, :client_id

  validates :category, inclusion: {
    in: CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym),
    message: "is not a valid credit category: %<value>",
  }, if: :credit?

  validates :category, inclusion: {
    in: CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym),
    message: "is not a valid debit category: %<value>",
  }, if: :debit?

  validates :operation, inclusion: { in: %i[credit debit],
                                     message: "%<value> is not a valid operation" }

  def initialize(category:, operation:, date:, amount:, client_id:)
    @category = category
    @operation = operation
    @date = date
    @amount = amount
    @client_id = client_id
  end

  def maintenance_out_payment?
    debit? && @category == :maintenance_out
  end

  def legal_aid_payment?
    debit? && @category == :legal_aid
  end

  def rent_or_mortgage_payment?
    debit? && @category == :rent_or_mortgage
  end

  def child_care_payment?
    debit? && @category == :child_care
  end

  def pension_contribution?
    debit? && @category == :pension_contribution
  end

  def council_tax_payment?
    debit? && @category == :council_tax
  end

  def priority_debt_repayment?
    debit? && @category == :priority_debt_repayment
  end

  def benefits?
    credit? && @category == :benefits
  end

  def friends_or_family?
    credit? && @category == :friends_or_family
  end

  def maintenance_in?
    credit? && @category == :maintenance_in
  end

  def property_or_lodger?
    credit? && @category == :property_or_lodger
  end

  def pension?
    credit? && @category == :pension
  end

private

  attr_reader :category, :operation

  def credit?
    @operation == :credit
  end

  def debit?
    @operation == :debit
  end
end
