module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment:, capitals_data:, date_of_birth:, receives_qualifying_benefit:)
        capital_subtotals = CapitalCollatorAndAssessor.call(assessment:, capitals_data:,
                                                            date_of_birth:, receives_qualifying_benefit:, total_disposable_income: 0)
        CalculationOutput.new(capital_subtotals:)
      end

      def partner(assessment:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:)
        capital_subtotals = CapitalCollatorAndAssessor.partner(assessment:, capitals_data:, partner_capitals_data:, date_of_birth:,
                                                               partner_date_of_birth:, receives_qualifying_benefit:,
                                                               total_disposable_income: 0)
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
