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

    subject(:summarizer) { described_class.call(assessment:, receives_qualifying_benefit: false, receives_asylum_support: false) }

    context "AssessmentProceedingTypeAssessor" do
      it "calls AssessmentProceedingTypeAssessor for each proceeding type code" do
        expect(Assessors::AssessmentProceedingTypeAssessor).to receive(:call).with(assessment:, proceeding_type_code: "DA003", receives_qualifying_benefit: false, receives_asylum_support: false)
        expect(Assessors::AssessmentProceedingTypeAssessor).to receive(:call).with(assessment:, proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false)
        summarizer
      end
    end

    context "result summarizer" do
      before do
        create :assessment_eligibility, assessment:, proceeding_type_code: "DA003", assessment_result: "eligible"
        create :assessment_eligibility, assessment:, proceeding_type_code: "SE014", assessment_result: "ineligible"

        allow(Assessors::AssessmentProceedingTypeAssessor).to receive(:call).with(assessment:, proceeding_type_code: "DA003", receives_qualifying_benefit: false, receives_asylum_support: false)
        allow(Assessors::AssessmentProceedingTypeAssessor).to receive(:call).with(assessment:, proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false)
      end

      it "calls the Results summarizer to update the assessment result" do
        expect(Utilities::ResultSummarizer).to receive(:call).with(%w[eligible ineligible]).and_call_original

        summarizer
        expect(assessment.assessment_result).to eq "partially_eligible"
      end
    end
  end
end
