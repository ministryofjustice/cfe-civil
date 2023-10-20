module Capital
  class Base
    attr_reader :applicant_capital_subtotals, :partner_capital_subtotals

    def initialize(applicant_capital_subtotals:, partner_capital_subtotals:,
                   submission_date:, level_of_help:)
      @applicant_capital_subtotals = applicant_capital_subtotals
      @partner_capital_subtotals = partner_capital_subtotals
      @submission_date = submission_date
      @level_of_help = level_of_help
    end
  end
end
