require "rails_helper"

describe CashTransaction do
  let(:assessment) { create :assessment }
  let(:gross_income_summary) { create :gross_income_summary, assessment: }
  let(:cash_transaction_category) { create :cash_transaction_category, operation: "debit", name: "child_care", gross_income_summary: }
  let(:cash_transaction_1) { create :cash_transaction, cash_transaction_category:, date: Date.new(2023, 4, 0o1) }
  let(:cash_transaction_2) { create :cash_transaction, cash_transaction_category:, date: Date.new(2023, 3, 0o1) }
  let(:cash_transaction_3) { create :cash_transaction, cash_transaction_category:, date: Date.new(2023, 2, 0o1) }

  describe "#by_operation_and_category" do
    it "display all the cash transactions in ascending order" do
      expect(gross_income_summary.cash_transactions.by_operation_and_category(:debit, :child_care)).to eq [cash_transaction_3, cash_transaction_2, cash_transaction_1]
    end
  end
end
