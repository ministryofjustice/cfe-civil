module Collators
  class HousingBenefitsCollator
    class << self
      def call(gross_income_summary:, state_benefits:)
        housing_benefit_amount = Calculators::MonthlyEquivalentCalculator.call(collection: housing_benefit_payments(state_benefits))
        housing_benefit_amount + monthly_housing_benefit_regular_transactions(gross_income_summary)
      end

    private

      def housing_benefit_payments(state_benefits)
        state_benefits.detect(&:housing_benefit?)&.state_benefit_payments || []
      end

      def monthly_housing_benefit_regular_transactions(gross_income_summary)
        txns = gross_income_summary.regular_transactions.with_operation_and_category(:credit, :housing_benefit)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end
    end
  end
end
