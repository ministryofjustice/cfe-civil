class Assessment < ApplicationRecord
  LEVELS_OF_HELP = %w[certificated controlled].freeze

  attr_accessor :level_of_help

  validates :remote_ip,
            :submission_date,
            presence: true

  validates :submission_date, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }

  # Just in case we get multiple POSTs to partner endpoint
  has_many :capital_summaries, dependent: :destroy
  has_many :gross_income_summaries, dependent: :destroy
  has_many :disposable_income_summaries, dependent: :destroy

  has_one :applicant_capital_summary
  has_one :applicant_gross_income_summary
  has_one :applicant_disposable_income_summary

  has_one :partner_capital_summary
  has_one :partner_gross_income_summary
  has_one :partner_disposable_income_summary

  has_many :explicit_remarks, dependent: :destroy
  has_many :proceeding_types,
           dependent: :destroy

  def proceeding_type_codes
    proceeding_types.order(:ccms_code).map(&:ccms_code)
  end
end
