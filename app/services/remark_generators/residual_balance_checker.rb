module RemarkGenerators
  class ResidualBalanceChecker
    class << self
      def call(capital_summary, assessed_capital, lower_capital_threshold)
        populate_remarks if residual_balance?(capital_summary, assessed_capital, lower_capital_threshold)
      end

    private

      def residual_balance?(capital_summary, assessed_capital, lower_capital_threshold)
        current_accounts = capital_summary.capital_items.where(description: "Current accounts")
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
