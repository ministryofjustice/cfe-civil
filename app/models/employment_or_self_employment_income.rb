class EmploymentOrSelfEmploymentIncome
  include ActiveModel::Model
  include ActiveModel::Attributes

  PAYMENT_FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly annually].freeze

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :prisoner_levy, :decimal
  attribute :gross, :decimal

  attribute :frequency, :string

  def entitles_childcare_allowance?
    entitles_employment_allowance? && gross.positive?
  end
end
