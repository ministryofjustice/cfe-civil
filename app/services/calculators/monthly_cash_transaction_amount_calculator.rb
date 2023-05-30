module Calculators
  class MonthlyCashTransactionAmountCalculator
    class << self
      def call(transactions)
        if transactions.empty?
          0.0
        else
          (transactions.sum(&:amount) / transactions.size).round(2)
        end
      end
    end
  end
end
