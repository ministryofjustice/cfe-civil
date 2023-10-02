module Collators
  class HousingCostsCollator
    Result = Data.define(:housing_benefit, :gross_housing_costs, :gross_housing_costs_bank, :net_housing_costs,
                         :gross_housing_costs_cash, :gross_housing_costs_regular) do
      def self.blank
        new(housing_benefit: 0,
            gross_housing_costs: 0,
            gross_housing_costs_bank: 0,
            gross_housing_costs_cash: 0,
            gross_housing_costs_regular: 0,
            net_housing_costs: 0)
      end
    end

    class << self
      def call(housing_cost_outgoings:, gross_income_summary:, submission_date:, person:, allow_negative_net:)
        monthly_housing_benefit = monthly_housing_benefit(gross_income_summary)

        housing_calculator = Calculators::HousingCostsCalculator.call(housing_cost_outgoings:, gross_income_summary:,
                                                                      monthly_housing_benefit:,
                                                                      submission_date:, housing_costs_cap_applies: housing_costs_cap_applies?(person))

        net_housing_costs = if allow_negative_net
                              housing_calculator.net_housing_costs
                            else
                              [housing_calculator.net_housing_costs, 0.0].max
                            end

        Result.new(
          housing_benefit: monthly_housing_benefit,
          gross_housing_costs: housing_calculator.gross_housing_costs,
          gross_housing_costs_bank: housing_calculator.gross_housing_costs_bank,
          gross_housing_costs_cash: housing_calculator.gross_housing_costs_cash,
          gross_housing_costs_regular: housing_calculator.gross_housing_costs_regular,
          net_housing_costs:,
        )
      end

    private

      def monthly_housing_benefit(gross_income_summary)
        housing_benefit_payments = Calculators::MonthlyEquivalentCalculator.call(
          collection: housing_benefit_records(gross_income_summary),
        )
        housing_benefit_payments + monthly_housing_benefit_regular_transactions(gross_income_summary)
      end

      def monthly_housing_benefit_regular_transactions(gross_income_summary)
        txns = gross_income_summary.regular_transactions.with_operation_and_category(:credit, :housing_benefit)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end

      def housing_benefit_records(gross_income_summary)
        gross_income_summary.housing_benefit_payments
      end

      def housing_costs_cap_applies?(person)
        person.single? && person.dependants.none?
      end
    end
  end
end
