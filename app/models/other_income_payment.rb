class OtherIncomePayment
  include ActiveModel::Validations
  attr_reader :name, :payment_date, :amount, :client_id

  validates :name, inclusion: { in: CFEConstants::HUMANIZED_INCOME_CATEGORIES }
  validates :payment_date, presence: true

  def initialize(name:, payment_date:, amount:, client_id:)
    @name = name
    @payment_date = payment_date
    @amount = amount
    @client_id = client_id
  end
end
