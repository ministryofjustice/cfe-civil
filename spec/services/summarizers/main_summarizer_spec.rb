require "rails_helper"

module Summarizers
  RSpec.describe MainSummarizer do
    let(:assessment) do
      create :assessment,
             :with_capital_summary,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             proceedings: [%w[DA003 A], %w[SE014 Z]]
    end

    subject(:summarizer) { described_class.call(assessment:, receives_qualifying_benefit: false, receives_asylum_support: false, gross_income_assessment_result: "pending") }

    context "AssessmentProceedingTypeSummarizer" do
      it "calls AssessmentProceedingTypeSummarizer for each proceeding type code" do
        expect(Summarizers::AssessmentProceedingTypeSummarizer).to receive(:call).with(assessment:, proceeding_type_code: "DA003", receives_qualifying_benefit: false, receives_asylum_support: false, gross_income_assessment_result: "pending")
        expect(Summarizers::AssessmentProceedingTypeSummarizer).to receive(:call).with(assessment:, proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false, gross_income_assessment_result: "pending")
        summarizer
      end
    end

    context "result summarizer" do
      before do
        create :assessment_eligibility, assessment:, proceeding_type_code: "DA003", assessment_result: "eligible"
        create :assessment_eligibility, assessment:, proceeding_type_code: "SE014", assessment_result: "ineligible"

        allow(Summarizers::AssessmentProceedingTypeSummarizer).to receive(:call).with(assessment:, proceeding_type_code: "DA003", receives_qualifying_benefit: false, receives_asylum_support: false, gross_income_assessment_result: "pending")
        allow(Summarizers::AssessmentProceedingTypeSummarizer).to receive(:call).with(assessment:, proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false, gross_income_assessment_result: "pending")
      end

      it "calls the Results summarizer to return the assessment result" do
        expect(Utilities::ResultSummarizer).to receive(:call).with(%w[eligible ineligible]).and_call_original
        expect(summarizer.assessment_result).to eq "partially_eligible"
      end
    end
  end
end
