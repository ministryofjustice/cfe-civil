module Calculators
  class DisregardedStateBenefitsCalculator
    class << self
      def call(state_benefits)
        result = 0.0
        state_benefits.each do |state_benefit|
          result += state_benefit.monthly_value if state_benefit.exclude_from_gross_income?
        end
        result
      end
    end
  end
end
