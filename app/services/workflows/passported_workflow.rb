module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment:, vehicles:, date_of_birth:, receives_qualifying_benefit:)
        capital_subtotals = CapitalCollatorAndAssessor.call(assessment:, vehicles:, date_of_birth:, receives_qualifying_benefit:)
        CalculationOutput.new(capital_subtotals:)
      end

      def partner(assessment:, vehicles:, partner_vehicles:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:)
        capital_subtotals = CapitalCollatorAndAssessor.partner(assessment:, vehicles:, partner_vehicles:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:)
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
