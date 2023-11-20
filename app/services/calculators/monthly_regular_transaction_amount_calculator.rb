module Calculators
  class MonthlyRegularTransactionAmountCalculator
    class << self
      def call(transactions)
        all_monthly_amounts = transactions.map do |transaction|
          Utilities::MonthlyAmountConverter.call(transaction.frequency, transaction.amount)
        end

        all_monthly_amounts.sum
      end
    end
  end
end
