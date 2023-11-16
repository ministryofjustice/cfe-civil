module Collators
  class HousingCostsCollator
    # The regular housing costs total is not exposed, so don't expose it here
    Result = Data.define(:housing_costs, :housing_costs_bank, :allowed_housing_costs,
                         :housing_costs_cash) do
      def self.blank
        new(housing_costs: 0,
            housing_costs_bank: 0,
            housing_costs_cash: 0,
            allowed_housing_costs: 0)
      end
    end

    class << self
      def call(housing_cost_outgoings:, submission_date:, person:, allow_negative_net:, housing_benefit:, cash_transactions:, regular_transactions:)
        housing_calculator = Calculators::HousingCostsCalculator.call(housing_cost_outgoings:,
                                                                      monthly_housing_benefit: housing_benefit,
                                                                      cash_transactions:,
                                                                      regular_transactions:,
                                                                      submission_date:, housing_costs_cap_applies: housing_costs_cap_applies?(person))

        allowed_housing_costs = if allow_negative_net
                                  housing_calculator.allowed_housing_costs
                                else
                                  [housing_calculator.allowed_housing_costs, 0.0].max
                                end

        Result.new(
          housing_costs: housing_calculator.housing_costs,
          housing_costs_bank: housing_calculator.housing_costs_bank,
          housing_costs_cash: housing_calculator.housing_costs_cash,
          allowed_housing_costs:,
        )
      end

    private

      def housing_costs_cap_applies?(person)
        person.single? && person.dependants.none?
      end
    end
  end
end
