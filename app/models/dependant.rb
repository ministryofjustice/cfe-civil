class Dependant
  include ActiveModel::Model
  include ActiveModel::Attributes

  DEFAULT_FREQUENCY = "monthly".freeze
  PAYMENT_FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly annually].freeze

  attribute :date_of_birth, :date
  attribute :relationship, :string
  attribute :in_full_time_education, :boolean
  attribute :assets_value, :decimal, default: 0
  attribute :submission_date, :date
  attribute :amount, :decimal, default: 0
  attribute :frequency, :string

  validates :date_of_birth, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }

  def becomes_16_on
    date_of_birth.years_since(16)
  end

  def under_15_years_old?
    date_of_birth > (submission_date - 15.years)
  end

  def under_16_years_old?
    date_of_birth > (submission_date - 16.years)
  end

  def in_full_time_education?
    in_full_time_education
  end

  def under_18_in_full_time_education?
    date_of_birth > (submission_date - 18.years) && in_full_time_education?
  end
end
