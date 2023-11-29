require "rails_helper"

RSpec.describe Calculators::PriorityDebtRepaymentCalculator, :calls_bank_holiday do
  around do |example|
    travel_to submission_date
    example.run
    travel_back
  end

  let(:assessment) do
    create(:assessment, :with_disposable_income_summary, :with_gross_income_summary, submission_date:)
  end

  subject(:priority_debt_repayment) do
    described_class.call(
      outgoings:,
      cash_transactions:,
      regular_transactions:,
      submission_date:,
    )
  end

  describe "#priority_debt_repayment" do
    let(:outgoings) { build_list(:priority_debt_repayment_outgoing, 3, amount: 100) }
    let(:regular_transactions) { build_list(:regular_transaction, 1, :priority_debt_repayment, amount: 300, frequency: "monthly") }
    let(:cash_transactions) do
      build_list(:cash_transaction, 3, category: :priority_debt_repayment, operation: :debit, amount: 200)
    end

    context "before MTR" do
      let(:submission_date) { Date.new(2023, 4, 20) }

      it "has the priority debt repayment value 0" do
        expect(priority_debt_repayment).to have_attributes(bank: 0, cash: 0, regular: 0, all_sources: 0)
      end
    end

    context "after MTR" do
      let(:submission_date) { Date.new(2525, 4, 20) }

      it "has the priority debt repayment value" do
        expect(priority_debt_repayment).to have_attributes(bank: 100, cash: 200, regular: 300, all_sources: 600)
      end
    end
  end
end
