class EmploymentOrSelfEmploymentIncome
  include ActiveModel::Model
  include ActiveModel::Attributes

  PAYMENT_FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly annually].freeze

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :gross, :decimal

  attribute :frequency, :string

  def has_positive_gross_income?
    gross.positive?
  end
end
