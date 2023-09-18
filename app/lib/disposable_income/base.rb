module DisposableIncome
  class Base
    attr_reader :partner_disposable_income_subtotals, :applicant_disposable_income_subtotals,
                :combined_total_disposable_income, :combined_total_outgoings_and_allowances

    def initialize(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:,
                   combined_total_disposable_income:, combined_total_outgoings_and_allowances:,
                   proceeding_types:, level_of_help:, submission_date:)
      @partner_disposable_income_subtotals = partner_disposable_income_subtotals
      @applicant_disposable_income_subtotals = applicant_disposable_income_subtotals
      @combined_total_disposable_income = combined_total_disposable_income
      @combined_total_outgoings_and_allowances = combined_total_outgoings_and_allowances
      @proceeding_types = proceeding_types
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def summarized_assessment_result
      Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
    end
  end
end
