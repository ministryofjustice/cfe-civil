require "rails_helper"

module RemarkGenerators
  RSpec.describe Orchestrator, :calls_bank_holiday do
    let(:assessment) { create :assessment }
    let(:state_benefits) { assessment.applicant_gross_income_summary.state_benefits }
    let(:state_benefit_payments) { state_benefits.first.state_benefit_payments }
    let(:other_income_sources) { assessment.applicant_gross_income_summary.other_income_sources }
    let(:other_income_payments) { other_income_sources.first.other_income_payments }
    let(:childcare_outgoings) { assessment.applicant_disposable_income_summary.childcare_outgoings }
    let(:maintenance_outgoings) { assessment.applicant_disposable_income_summary.maintenance_outgoings }
    let(:housing_outgoings) { assessment.applicant_disposable_income_summary.housing_cost_outgoings }
    let(:legal_aid_outgoings) { assessment.applicant_disposable_income_summary.legal_aid_outgoings }
    let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date) }
    let(:employment_payments) { employments.first.employment_payments }
    let(:liquid_capital_items) { build_list(:liquid_capital_item, 2) }

    before do
      create(:disposable_income_summary, :with_everything, assessment:)
      create(:gross_income_summary, :with_everything, assessment:)
      create(:capital_summary, :with_eligibilities, assessment:)
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

      described_class.call(liquid_capital_items:,
                           lower_capital_threshold: 100,
                           child_care_bank: 0,
                           outgoings: assessment.applicant_disposable_income_summary.outgoings,
                           employments:,
                           gross_income_summary: assessment.applicant_gross_income_summary, assessed_capital: 0)
    end
  end
end
