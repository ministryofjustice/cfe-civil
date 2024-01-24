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

  has_many :explicit_remarks, dependent: :destroy
end
