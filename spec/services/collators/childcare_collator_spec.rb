require "rails_helper"

module Collators
  RSpec.describe ChildcareCollator, :calls_bank_holiday do
    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.applicant_gross_income_summary }

      let(:childcare_outgoings) do
        [
          build(:childcare_outgoing, payment_date: Date.current, amount: 155.63),
          build(:childcare_outgoing, payment_date: 1.month.ago, amount: 155.63),
          build(:childcare_outgoing, payment_date: 2.months.ago, amount: 155.63),
        ]
      end

      subject(:collator) do
        described_class.call(cash_transactions: gross_income_summary.cash_transactions(:debit, :child_care), childcare_outgoings:, eligible_for_childcare:)
      end

      context "Not eligible for childcare" do
        let(:eligible_for_childcare) { false }

        it "does not update the childcare value on the disposable income summary" do
          expect(collator.bank).to eq 0.0
        end
      end

      context "Eligible for childcare" do
        let(:eligible_for_childcare) { true }

        it "updates the childcare value on the disposable income summary" do
          expect(collator.bank).to eq 155.63
        end
      end
    end
  end
end
