module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment:, capitals_data:, date_of_birth:, receives_qualifying_benefit:, receives_asylum_support:)
        capital_subtotals = CapitalCollatorAndAssessor.call(assessment:, capitals_data:,
                                                            date_of_birth:, receives_qualifying_benefit:, total_disposable_income: 0)
        main_summarizer = Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit:, receives_asylum_support:)
        CalculationOutput.new(capital_subtotals:, assessment_result: main_summarizer.assessment_result)
      end

      def partner(assessment:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:, receives_asylum_support:)
        capital_subtotals = CapitalCollatorAndAssessor.partner(assessment:, capitals_data:, partner_capitals_data:, date_of_birth:,
                                                               partner_date_of_birth:, receives_qualifying_benefit:,
                                                               total_disposable_income: 0)
        main_summarizer = Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit:, receives_asylum_support:)
        CalculationOutput.new(capital_subtotals:, assessment_result: main_summarizer.assessment_result)
      end
    end
  end
end
