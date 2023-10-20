module DisposableIncome
  class Subtotals < Base
    def initialize(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:,
                   proceeding_types:, submission_date:, level_of_help:)
      super(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:,
            proceeding_types:, level_of_help:, submission_date:)
    end

    def summarized_assessment_result
      Utilities::ResultSummarizer.call(disposable_eligibilities.map(&:assessment_result))
    end

    def ineligible?
      summarized_assessment_result == :ineligible
    end

    def eligibilities
      Creators::DisposableIncomeEligibilityCreator.call(proceeding_types: @proceeding_types,
                                                        submission_date: @submission_date,
                                                        level_of_help: @level_of_help,
                                                        total_disposable_income: combined_total_disposable_income)
    end

    def income_contribution
      contribution_required? ? calculate_contribution : 0.0
    end

  private

    def disposable_eligibilities
      Creators::DisposableIncomeEligibilityCreator.call(proceeding_types: @proceeding_types,
                                                        submission_date: @submission_date,
                                                        level_of_help: @level_of_help,
                                                        total_disposable_income: combined_total_disposable_income)
    end

    def calculate_contribution
      Calculators::IncomeContributionCalculator.call(combined_total_disposable_income, @submission_date)
    end

    def contribution_required?
      disposable_eligibilities.map(&:assessment_result).include?("contribution_required")
    end
  end
end
