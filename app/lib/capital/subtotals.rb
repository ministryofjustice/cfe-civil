module Capital
  class Subtotals < Base
    def initialize(applicant_capital_subtotals:, partner_capital_subtotals:,
                   submission_date:, level_of_help:)
      super(applicant_capital_subtotals:, partner_capital_subtotals:, submission_date:, level_of_help:)
    end

    def eligibilities(proceeding_types)
      Creators::CapitalEligibilityCreator.call proceeding_types:,
                                               submission_date: @submission_date,
                                               level_of_help: @level_of_help,
                                               assessed_capital: combined_assessed_capital
    end

    def assessment_results(proceeding_types)
      Creators::CapitalEligibilityCreator.assessment_results proceeding_types:,
                                                             submission_date: @submission_date,
                                                             level_of_help: @level_of_help,
                                                             assessed_capital: combined_assessed_capital
    end

    def combined_assessed_capital
      @applicant_capital_subtotals.assessed_capital + @partner_capital_subtotals.assessed_capital
    end

    def capital_contribution(proceeding_types)
      threshold = eligibilities(proceeding_types).map(&:lower_threshold).min
      [0, combined_assessed_capital - threshold].max
    end
  end
end
