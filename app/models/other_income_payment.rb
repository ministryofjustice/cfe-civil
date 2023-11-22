class OtherIncomePayment
  include ActiveModel::Validations
  attr_reader :category, :payment_date, :amount, :client_id

  validates :category, inclusion: { in: CFEConstants::HUMANIZED_INCOME_CATEGORIES.map(&:to_sym) }
  validates :payment_date, presence: true

  def initialize(category:, payment_date:, amount:, client_id:)
    @category = category
    @payment_date = payment_date
    @amount = amount
    @client_id = client_id
  end
end
