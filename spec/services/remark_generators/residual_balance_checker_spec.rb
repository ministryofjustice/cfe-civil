require "rails_helper"

module RemarkGenerators
  RSpec.describe ResidualBalanceChecker do
    let(:assessment) { create :assessment, applicant_capital_summary: capital_summary }
    let(:capital_summary) { create :capital_summary, :with_eligibilities }
    let(:assessed_capital) { 4000 }

    context "when a residual balance exists and assessed capital is above the lower threshold" do
      before { create :liquid_capital_item, description: "Current accounts", value: 100, capital_summary: }

      it "adds the remark when a residual balance exists" do
        expect(described_class.call(assessment.applicant_capital_summary, assessed_capital, 0))
          .to eq(RemarksData.new(type: :current_account_balance, issue: :residual_balance, ids: []))
      end
    end

    context "when there is no residual balance" do
      it "does not update the remarks class" do
        expect(described_class.call(assessment.applicant_capital_summary, assessed_capital, 0)).to be_nil
      end
    end

    context "when capital assessment is below the lower threshold" do
      let(:capital_summary) { create :capital_summary, :with_eligibilities }

      it "does not update the remarks class" do
        expect(described_class.call(assessment.applicant_capital_summary, 0, 0)).to be_nil
      end
    end

    context "when there is no residual balance and assessed capital is below the lower threshold" do
      before { create :liquid_capital_item, description: "Current accounts", value: 0, capital_summary: }

      let(:capital_summary) { create :capital_summary, :with_eligibilities }

      it "does not update the remarks class" do
        expect(described_class.call(assessment.applicant_capital_summary, assessed_capital, 0)).to be_nil
      end
    end

    context "with multiple current accounts" do
      context "when there is a residual_balance in any account" do
        before do
          create(:liquid_capital_item, description: "Current accounts", value: 100, capital_summary:)
          create :liquid_capital_item, description: "Current accounts", value: -200, capital_summary:
        end

        it "adds the remark when a residual balance exists" do
          expect(described_class.call(assessment.applicant_capital_summary, assessed_capital, 0))
            .to eq(RemarksData.new(type: :current_account_balance, issue: :residual_balance, ids: []))
        end
      end

      context "when there is no residual_balance in any account" do
        before do
          create(:liquid_capital_item, description: "Current accounts", value: 0, capital_summary:)
          create :liquid_capital_item, description: "Current accounts", value: -100, capital_summary:
        end

        it "does not update the remarks class" do
          expect(described_class.call(assessment.applicant_capital_summary, assessed_capital, 0)).to be_nil
        end
      end
    end
  end
end
