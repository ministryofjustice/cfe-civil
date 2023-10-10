module Collators
  class DisposableIncomeCollator
    Result = Data.define(:legal_aid_cash, :maintenance_out_cash) do
      def self.blank
        new(legal_aid_cash: 0, maintenance_out_cash: 0)
      end
    end

    class << self
      def call(gross_income_summary:)
        Result.new(legal_aid_cash: monthly_cash_by_category(gross_income_summary, :legal_aid),
                   maintenance_out_cash: monthly_cash_by_category(gross_income_summary, :maintenance_out))
      end

      def monthly_cash_by_category(gross_income_summary, category)
        cash_transactions = gross_income_summary.cash_transactions(:debit, category)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
      end
    end
  end
end
