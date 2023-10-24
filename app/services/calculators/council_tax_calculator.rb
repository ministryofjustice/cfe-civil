module Calculators
  class CouncilTaxCalculator
    Result = Data.define(:bank, :cash, :regular) do
      def all_sources
        bank + cash + regular
      end

      def self.blank
        new(bank: 0, cash: 0, regular: 0)
      end
    end

    class << self
      def call(outgoings:, cash_transactions:, regular_transactions:)
        if (outgoings + cash_transactions + regular_transactions).any?
          monthly_bank = Calculators::MonthlyEquivalentCalculator.call(collection: outgoings)
          monthly_cash = Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
          monthly_regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(regular_transactions)
          Result.new(bank: monthly_bank.round(2), cash: monthly_cash.round(2), regular: monthly_regular.round(2))
        else
          Result.blank
        end
      end
    end
  end
end
