class SelfEmployment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :gross_income, :decimal
  attribute :frequency, :string

  validates :tax, :national_insurance, :gross_income, :frequency, presence: true
end
