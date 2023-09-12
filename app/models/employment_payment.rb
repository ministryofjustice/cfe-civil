class EmploymentPayment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :client_id, :string
  attribute :gross_income, :decimal, default: 0.0
  attribute :benefits_in_kind, :decimal, default: 0.0
  attribute :tax, :decimal, default: 0.0
  attribute :national_insurance, :decimal, default: 0.0
end
