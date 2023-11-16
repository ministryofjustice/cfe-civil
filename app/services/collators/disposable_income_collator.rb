module Collators
  class DisposableIncomeCollator
    Result = Data.define(:legal_aid_cash, :maintenance_out_cash) do
      def self.blank
        new(legal_aid_cash: 0, maintenance_out_cash: 0)
      end
    end

    class << self
      def call(cash_transactions:)
        Result.new(legal_aid_cash: monthly_cash_by_category(cash_transactions.select(&:legal_aid_payment?)),
                   maintenance_out_cash: monthly_cash_by_category(cash_transactions.select(&:maintenance_out_payment?)))
      end

      def monthly_cash_by_category(cash_transactions)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
      end
    end
  end
end
