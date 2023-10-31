module RemarkGenerators
  class PaymentChecker
    class << self
      def call(cash_transactions:, regular_transactions:, outgoings:)
        priority_debt_checker(cash_transactions:, regular_transactions:, outgoings:)
      end

    private

      def priority_debt_checker(cash_transactions:, regular_transactions:, outgoings:)
        ids = []
        remarks = []
        priority_debt_cash_transactions = cash_transactions.by_operation_and_category(:debit, :priority_debt_repayment)
        priority_debt_regular_transactions = regular_transactions.with_operation_and_category(:debit, :priority_debt_repayment)
        priority_debt_outgoings = outgoings.select { |o| o.instance_of? Outgoings::PriorityDebtRepayment }

        if priority_debt_cash_transactions.any? || priority_debt_regular_transactions.any? || priority_debt_outgoings.any?
          ids << priority_debt_cash_transactions.map(&:client_id) if priority_debt_cash_transactions.any?
          ids << priority_debt_outgoings.map(&:client_id) if priority_debt_outgoings.any?
          remarks << RemarksData.new(type: :priority_debt, issue: :priority_debt, ids: ids.flatten.compact.uniq)
        end
        remarks
      end
    end
  end
end
