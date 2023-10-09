module RemarkGenerators
  class ResidualBalanceChecker
    class << self
      def call(liquid_capital_items, assessed_capital, lower_capital_threshold)
        populate_remarks if residual_balance?(liquid_capital_items, assessed_capital, lower_capital_threshold)
      end

    private

      def residual_balance?(liquid_capital_items, assessed_capital, lower_capital_threshold)
        current_accounts = liquid_capital_items.select { |lci| lci.description == "Current accounts" }
        highest_current_account_balance = current_accounts.map(&:value).max || 0
        capital_exceeds_lower_threshold?(assessed_capital, lower_capital_threshold) && highest_current_account_balance.positive?
      end

      def capital_exceeds_lower_threshold?(assessed_capital, lower_capital_threshold)
        assessed_capital > lower_capital_threshold
      end

      def populate_remarks
        RemarksData.new(type: :current_account_balance, issue: :residual_balance, ids: [])
      end
    end
  end
end
