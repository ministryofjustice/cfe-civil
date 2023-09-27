module Calculators
  class MonthlyCashTransactionAmountCalculator
    class << self
      def call(collection:)
        if collection.empty?
          0.0
        else
          (collection.sum(&:amount) / collection.size).round(2)
        end
      end
    end
  end
end
