module Calculators
  class StateBenefitsCalculator
    class << self
      def call(state_benefits)
        total = 0.0

        state_benefits.each do |state_benefit|
          monthly_value = Calculators::MonthlyEquivalentCalculator.call(
            collection: state_benefit.state_benefit_payments,
          )
          total += monthly_value unless state_benefit.exclude_from_gross_income
        end
        total
      end
    end
  end
end
