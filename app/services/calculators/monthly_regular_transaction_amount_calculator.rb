module Calculators
  class MonthlyRegularTransactionAmountCalculator
    class << self
      def call(gross_income_summary:, operation:, category:)
        transactions = gross_income_summary.regular_transactions.where(operation:).where(category:)
        result_for_transactions(transactions)
      end

      def result_for_transactions(transactions)
        all_monthly_amounts = transactions.each_with_object([]) do |transaction, amounts|
          amounts << Utilities::MonthlyAmountConverter.call(transaction.frequency, transaction.amount)
        end

        all_monthly_amounts.sum
      end
    end
  end
end
