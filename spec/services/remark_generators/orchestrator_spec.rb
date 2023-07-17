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
    let(:employment_payments) { assessment.employments.first.employment_payments }

    before do
      create(:disposable_income_summary, :with_everything, assessment:)
      create(:gross_income_summary, :with_everything, :with_employment, assessment:)
      create(:capital_summary, :with_eligibilities, assessment:)
    end

    it "calls the checkers with each collection" do
      expect(MultiBenefitChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, state_benefit_payments).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, state_benefit_payments).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, other_income_payments).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, childcare_outgoings).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, maintenance_outgoings).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, housing_outgoings).and_call_original
      expect(AmountVariationChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, legal_aid_outgoings).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, state_benefit_payments).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, other_income_payments).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, childcare_outgoings).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, maintenance_outgoings).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, housing_outgoings).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, legal_aid_outgoings).and_call_original
      expect(FrequencyChecker).to receive(:call).with(assessment.applicant_disposable_income_summary, employment_payments, :date).and_call_original

      expect(ResidualBalanceChecker).to receive(:call).with(assessment.applicant_capital_summary, 0, 100).and_call_original

      described_class.call(assessment:, capital_summary: assessment.applicant_capital_summary,
                           lower_capital_threshold: 100,
                           disposable_income_summary: assessment.applicant_disposable_income_summary,
                           employments: assessment.employments,
                           gross_income_summary: assessment.applicant_gross_income_summary, assessed_capital: 0)
    end
  end
end
