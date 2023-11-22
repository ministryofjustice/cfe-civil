class OtherIncomePayment
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  validates :name, inclusion: { in: CFEConstants::HUMANIZED_INCOME_CATEGORIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_date, presence: true

  attribute :name
  attribute :payment_date, :date
  attribute :amount, :decimal
  attribute :client_id
end
