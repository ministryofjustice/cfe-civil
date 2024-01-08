module Capital
  class CapitalResultWithPartner < CapitalResult
    attr_reader :partner_capital_subtotals

    def initialize(applicant_capital_subtotals:, partner_capital_subtotals:,
                   submission_date:, level_of_help:)
      super(applicant_capital_subtotals:, submission_date:, level_of_help:)
      @partner_capital_subtotals = partner_capital_subtotals
    end

    def combined_assessed_capital
      @applicant_capital_subtotals.assessed_capital + @partner_capital_subtotals.assessed_capital
    end
  end
end
