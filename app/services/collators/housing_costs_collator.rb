module Collators
  class HousingCostsCollator
    # The regular housing costs total is not exposed, so don't expose it here
    Result = Data.define(:gross_housing_costs, :gross_housing_costs_bank, :net_housing_costs,
                         :gross_housing_costs_cash) do
      def self.blank
        new(gross_housing_costs: 0,
            gross_housing_costs_bank: 0,
            gross_housing_costs_cash: 0,
            net_housing_costs: 0)
      end
    end

    class << self
      def call(housing_cost_outgoings:, gross_income_summary:, submission_date:, person:, allow_negative_net:, housing_benefit:)
        housing_calculator = Calculators::HousingCostsCalculator.call(housing_cost_outgoings:, gross_income_summary:,
                                                                      monthly_housing_benefit: housing_benefit,
                                                                      submission_date:, housing_costs_cap_applies: housing_costs_cap_applies?(person))

        net_housing_costs = if allow_negative_net
                              housing_calculator.net_housing_costs
                            else
                              [housing_calculator.net_housing_costs, 0.0].max
                            end

        Result.new(
          gross_housing_costs: housing_calculator.gross_housing_costs,
          gross_housing_costs_bank: housing_calculator.gross_housing_costs_bank,
          gross_housing_costs_cash: housing_calculator.gross_housing_costs_cash,
          net_housing_costs:,
        )
      end

    private

      def housing_costs_cap_applies?(person)
        person.single? && person.dependants.none?
      end
    end
  end
end
