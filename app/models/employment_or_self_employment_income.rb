class EmploymentOrSelfEmploymentIncome
  include ActiveModel::Model
  include ActiveModel::Attributes

  PAYMENT_FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly annually].freeze

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :gross, :decimal
  attribute :frequency, :string
  attribute :prisoner_levy, :decimal, default: 0.0
  attribute :student_debt_repayment, :decimal, default: 0.0

  def entitles_childcare_allowance?
    entitles_employment_allowance? && gross.positive?
  end
end
