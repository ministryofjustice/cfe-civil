class Assessment < ApplicationRecord
  CERTIFICATED = "certificated".freeze
  CONTROLLED = "controlled".freeze
  LEVELS_OF_HELP = [CERTIFICATED, CONTROLLED].freeze

  attr_accessor :level_of_help, :controlled_legal_representation, :not_aggregated_no_income_low_capital

  validates :remote_ip,
            :submission_date,
            presence: true

  validates :submission_date, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }

  # Just in case we get multiple POSTs to partner endpoint
  has_many :gross_income_summaries, dependent: :destroy
  has_many :disposable_income_summaries, dependent: :destroy

  has_one :applicant_gross_income_summary
  has_one :applicant_disposable_income_summary

  has_one :partner_gross_income_summary
  has_one :partner_disposable_income_summary

  has_many :explicit_remarks, dependent: :destroy
  has_many :proceeding_types,
           dependent: :destroy

  def proceeding_type_codes
    proceeding_types.order(:ccms_code).map(&:ccms_code)
  end
end
