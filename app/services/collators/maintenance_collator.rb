module Collators
  class MaintenanceCollator
    Result = Data.define(:cash, :bank) do
      def self.blank
        new(cash: 0, bank: 0)
      end
    end

    class << self
      def call(maintenance_outgoings:, cash_transactions:)
        Result.new(bank: maintenance_bank(maintenance_outgoings), cash: maintenance_cash(cash_transactions))
      end

    private

      def maintenance_bank(maintenance_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: maintenance_outgoings)
      end

      def maintenance_cash(cash_transactions)
        Calculators::MonthlyCashTransactionAmountCalculator.call(cash_transactions)
      end
    end
  end
end
