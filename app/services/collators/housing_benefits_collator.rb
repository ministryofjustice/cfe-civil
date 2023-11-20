module Collators
  class HousingBenefitsCollator
    class << self
      def call(state_benefits:, regular_transactions:)
        housing_benefit_amount = Calculators::MonthlyEquivalentCalculator.call(collection: housing_benefit_payments(state_benefits))
        housing_benefit_amount + monthly_housing_benefit_regular_transactions(regular_transactions)
      end

    private

      def housing_benefit_payments(state_benefits)
        state_benefits.detect(&:housing_benefit?)&.state_benefit_payments || []
      end

      def monthly_housing_benefit_regular_transactions(regular_transactions)
        txns = regular_transactions.select(&:housing_benefit?)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end
    end
  end
end
