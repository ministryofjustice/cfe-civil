class SelfEmploymentIncome
  include ActiveModel::Model
  include ActiveModel::Attributes

  PAYMENT_FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly].freeze

  attribute :receiving_only_statutory_sick_or_maternity_pay, :boolean

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :gross, :decimal
  attribute :benefits_in_kind, :decimal, default: 0

  attribute :frequency, :string
  attribute :is_employment, :boolean

  validates :tax, :national_insurance, :gross, :frequency, presence: true
  validates :frequency, inclusion: { in: PAYMENT_FREQUENCIES, allow_nil: true }

  def actively_working?
    is_employment && !receiving_only_statutory_sick_or_maternity_pay
  end
end
