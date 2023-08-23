module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment:, vehicles:, date_of_birth:, receives_qualifying_benefit:,
               liquid_capital_items:, non_liquid_capital_items:)
        capital_subtotals = CapitalCollatorAndAssessor.call(assessment:, vehicles:, liquid_capital_items:, non_liquid_capital_items:,
                                                            date_of_birth:, receives_qualifying_benefit:, total_disposable_income: 0)
        CalculationOutput.new(capital_subtotals:)
      end

      def partner(assessment:, vehicles:, partner_vehicles:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:,
                  liquid_capital_items:, non_liquid_capital_items:,
                  partner_liquid_capital_items:, partner_non_liquid_capital_items:)
        capital_subtotals = CapitalCollatorAndAssessor.partner(assessment:, vehicles:, partner_vehicles:, date_of_birth:,
                                                               partner_date_of_birth:, receives_qualifying_benefit:,
                                                               liquid_capital_items:, non_liquid_capital_items:,
                                                               partner_liquid_capital_items:, partner_non_liquid_capital_items:,
                                                               total_disposable_income: 0)
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
