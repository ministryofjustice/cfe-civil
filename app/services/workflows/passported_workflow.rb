module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment:, vehicles:, partner_vehicles:)
        capital_subtotals = CapitalCollatorAndAssessor.call(assessment:, vehicles:, partner_vehicles:)
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
