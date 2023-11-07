module DisposableIncome
  class Subtotals < Base
    def initialize(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:,
                   submission_date:, level_of_help:)
      super(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:)
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def summarized_assessment_result(proceeding_types)
      Utilities::ResultSummarizer.call(assessment_results(proceeding_types).values)
    end

    def ineligible?(proceeding_types)
      summarized_assessment_result(proceeding_types) == :ineligible
    end

    def eligibilities(proceeding_types)
      Creators::DisposableIncomeEligibilityCreator.call(proceeding_types:,
                                                        submission_date: @submission_date,
                                                        level_of_help: @level_of_help,
                                                        total_disposable_income: combined_total_disposable_income)
    end

    def income_contribution(proceeding_types)
      contribution_required?(proceeding_types) ? calculate_contribution : 0.0
    end

  private

    def assessment_results(proceeding_types)
      Creators::DisposableIncomeEligibilityCreator.assessment_results(proceeding_types:,
                                                                      submission_date: @submission_date,
                                                                      level_of_help: @level_of_help,
                                                                      total_disposable_income: combined_total_disposable_income)
    end

    def calculate_contribution
      Calculators::IncomeContributionCalculator.call(combined_total_disposable_income, @submission_date)
    end

    def contribution_required?(proceeding_types)
      assessment_results(proceeding_types).value?("contribution_required")
    end
  end
end
