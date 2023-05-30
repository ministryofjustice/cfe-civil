module Collators
  class ChildcareCollator
    Result = Data.define(:cash, :bank)

    class << self
      def call(cash_transactions:, childcare_outgoings:, eligible_for_childcare:)
        if eligible_for_childcare
          Result.new(bank: child_care_bank(childcare_outgoings), cash: child_care_cash(cash_transactions))
        else
          Result.new(bank: 0, cash: 0)
        end
      end

    private

      def child_care_bank(childcare_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: childcare_outgoings)
      end

      def child_care_cash(cash_transactions)
        Calculators::MonthlyCashTransactionAmountCalculator.call(cash_transactions)
      end
    end
  end
end
