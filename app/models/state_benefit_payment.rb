class StateBenefitPayment
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :payment_date, :date
  attribute :amount, :decimal
  attribute :client_id, :string

  attr_accessor :flags
end
