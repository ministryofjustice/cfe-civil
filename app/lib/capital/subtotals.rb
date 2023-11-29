module Capital
  class Subtotals < Base
    def initialize(applicant_capital_subtotals:,
                   submission_date:, level_of_help:)
      super(applicant_capital_subtotals)
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def partner_capital_subtotals
      PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
    end

    def assessed?
      true
    end

    def summarized_assessment_result(proceeding_types)
      Utilities::ResultSummarizer.call(assessment_results(proceeding_types).values)
    end

    def combined_assessed_capital
      @applicant_capital_subtotals.assessed_capital
    end

    def capital_contribution(proceeding_types)
      lower_capital_threshold = Creators::CapitalEligibilityCreator.lower_capital_threshold(proceeding_types:,
                                                                                            level_of_help: @level_of_help,
                                                                                            submission_date: @submission_date)
      [0, combined_assessed_capital - lower_capital_threshold].max
    end

  private

    def assessment_results(proceeding_types)
      Creators::CapitalEligibilityCreator.assessment_results proceeding_types:,
                                                             submission_date: @submission_date,
                                                             level_of_help: @level_of_help,
                                                             assessed_capital: combined_assessed_capital
    end
  end
end
