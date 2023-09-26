module Collators
  class PensionContributionCollator
    Result = Data.define(:cash, :bank, :regular) do
      def self.blank
        new(cash: 0, bank: 0, regular: 0)
      end
    end

    class << self
      def call(outgoings:, cash_transactions:, regular_transactions:)
        Result.new(bank: outgoings, cash: cash_transactions, regular: regular_transactions)
      end
    end
  end
end
