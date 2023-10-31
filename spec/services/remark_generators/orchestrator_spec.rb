require "rails_helper"

module RemarkGenerators
  RSpec.describe Orchestrator, :calls_bank_holiday do
    let(:submission_date) { Date.new(2023, 4, 20) }
    let(:assessment) { create :assessment, submission_date: }
    let(:state_benefits) do
      [StateBenefit.new(state_benefit_payments: build_list(:state_benefit_payment, 1),
                        state_benefit_name: "anything",
                        exclude_from_gross_income: false)]
    end
    let(:state_benefit_payments) { state_benefits.first.state_benefit_payments }
    let(:other_income_sources) { assessment.applicant_gross_income_summary.other_income_sources }
    let(:other_income_payments) { other_income_sources.first.other_income_payments }
    let(:childcare_outgoings) { build_list(:childcare_outgoing, 1) }
    let(:maintenance_outgoings) { build_list(:maintenance_outgoing, 1) }
    let(:housing_outgoings) { build_list(:housing_cost_outgoing, 1) }
    let(:legal_aid_outgoings) { build_list(:legal_aid_outgoing, 1) }
    let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date) }
    let(:employment_payments) { employments.first.employment_payments }
    let(:liquid_capital_items) { build_list(:liquid_capital_item, 2) }
    let(:gross_income_summary) { create(:gross_income_summary, :with_everything, assessment:) }

    before do
      create(:disposable_income_summary, assessment:)
      create(:capital_summary, assessment:)
      create_list(:regular_transaction, 1, :priority_debt_repayment, amount: 300, frequency: "monthly", gross_income_summary:)
    end

    subject(:orchestrator) do
      described_class.call(liquid_capital_items:,
                           state_benefits:,
                           lower_capital_threshold: 100,
                           child_care_bank: 0,
                           outgoings: childcare_outgoings + housing_outgoings + legal_aid_outgoings + maintenance_outgoings,
                           employments:,
                           other_income_sources: assessment.applicant_gross_income_summary.other_income_sources,
                           cash_transactions: assessment.applicant_gross_income_summary.cash_transactions,
                           regular_transactions: assessment.applicant_gross_income_summary.regular_transactions,
                           assessed_capital: 0,
                           submission_date:)
    end

    it "calls the checkers with each collection" do
      expect(MultiBenefitChecker).to receive(:call).with(state_benefit_payments).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: state_benefit_payments, child_care_bank: 0).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: other_income_payments, child_care_bank: 0).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: childcare_outgoings, child_care_bank: 0).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: maintenance_outgoings, child_care_bank: 0).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: housing_outgoings, child_care_bank: 0).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(collection: legal_aid_outgoings, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: state_benefit_payments, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: other_income_payments, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: childcare_outgoings, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: maintenance_outgoings, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: housing_outgoings, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: legal_aid_outgoings, child_care_bank: 0).and_call_original
      expect(FrequencyChecker).to receive(:call).with(collection: employment_payments, child_care_bank: 0, date_attribute: :date).and_call_original

      expect(ResidualBalanceChecker).to receive(:call).with(liquid_capital_items, 0, 100).and_call_original

      orchestrator
    end

    context "pre MTR" do
      it "return RemarksData array without priority_debt remark" do
        expect(orchestrator).not_to include(RemarksData.new(type: :priority_debt, issue: :priority_debt, ids: []))
      end
    end

    context "post MTR" do
      let(:submission_date) { Date.new(2525, 4, 20) }

      it "return RemarksData array with priority_debt remark" do
        expect(orchestrator).to include(RemarksData.new(type: :priority_debt, issue: :priority_debt, ids: []))
      end
    end
  end
end
