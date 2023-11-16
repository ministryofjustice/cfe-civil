require "rails_helper"

module RemarkGenerators
  RSpec.describe PaymentChecker do
    let(:operation) { :debit }
    let(:category) { :priority_debt_repayment }
    let(:assessment) { create(:assessment) }
    let(:gross_income_summary) { create(:gross_income_summary, assessment:) }
    let(:disposable_income_summary) { create(:disposable_income_summary, assessment:) }
    let(:regular_transactions) { gross_income_summary.regular_transactions }
    let(:outgoings) { build_list(:priority_debt_repayment_outgoing, 3, client_id: "client_id_2") }

    subject(:payment_checker) { described_class.call(cash_transactions:, regular_transactions:, outgoings:) }

    context "with payments" do
      let(:cash_transactions) { build_list(:cash_transaction, 1, category:, operation:, client_id: "client_id_1") }

      let(:regular_transactions) do
        build_list(:regular_transaction, 3, category:, operation:)
      end

      it "returns remarks array" do
        expect(payment_checker).to eq [RemarksData.new(type: :priority_debt, issue: :priority_debt, ids: %w[client_id_1 client_id_2])]
      end
    end

    context "without payments" do
      let(:outgoings) { [] }
      let(:regular_transactions) { [] }
      let(:cash_transactions) { [] }

      it "returns no remarks" do
        expect(payment_checker).to eq []
      end
    end
  end
end
