module Collators
  class ChildcareCollator
    Result = Data.define(:cash, :bank) do
      def self.blank
        new(cash: 0, bank: 0)
      end
    end

    class << self
      def call(cash_transactions:, childcare_outgoings:)
        Result.new(bank: child_care_bank(childcare_outgoings), cash: child_care_cash(cash_transactions))
      end

    private

      def child_care_bank(childcare_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: childcare_outgoings)
      end

      def child_care_cash(cash_transactions)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
      end
    end
  end
end
