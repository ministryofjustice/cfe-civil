module RemarkGenerators
  class PaymentChecker
    class << self
      def call(cash_transactions:, regular_transactions:, outgoings:)
        priority_debt_checker(cash_transactions:, regular_transactions:, outgoings:)
      end

    private

      def priority_debt_checker(cash_transactions:, regular_transactions:, outgoings:)
        priority_debt_cash_transactions = cash_transactions.by_operation_and_category(:debit, :priority_debt_repayment)
        priority_debt_regular_transactions = regular_transactions.with_operation_and_category(:debit, :priority_debt_repayment)
        priority_debt_outgoings = outgoings.select { |o| o.instance_of? Outgoings::PriorityDebtRepayment }

        if priority_debt_cash_transactions.any? || priority_debt_regular_transactions.any? || priority_debt_outgoings.any?
          ids = []
          ids << priority_debt_cash_transactions.map(&:client_id)
          ids << priority_debt_outgoings.map(&:client_id)
          [RemarksData.new(type: :priority_debt, issue: :priority_debt, ids: ids.flatten.compact.uniq)]
        else
          []
        end
      end
    end
  end
end
