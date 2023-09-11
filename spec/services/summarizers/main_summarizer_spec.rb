require "rails_helper"

module Summarizers
  RSpec.describe MainSummarizer do
    let(:assessment) do
      create :assessment,
             :with_eligibilities,
             :with_capital_summary,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             proceedings: [%w[DA003 A], %w[SE014 Z]]
    end

    subject(:summarizer) do
      described_class.call(assessment:, receives_qualifying_benefit: false, receives_asylum_support: false,
                           gross_income_eligibilities: [
                             build(:gross_income_eligibility, proceeding_type_code: "DA003", assessment_result: "eligible"),
                             build(:gross_income_eligibility, proceeding_type_code: "SE014", assessment_result: "eligible"),
                           ],
                           disposable_income_eligibilities: [
                             build(:gross_income_eligibility, proceeding_type_code: "DA003", assessment_result: "ineligible"),
                             build(:gross_income_eligibility, proceeding_type_code: "SE014", assessment_result: "ineligible"),
                           ],
                           capital_eligibilities: [
                             build(:gross_income_eligibility, proceeding_type_code: "DA003", assessment_result: "contribution_required"),
                             build(:gross_income_eligibility, proceeding_type_code: "SE014", assessment_result: "contribution_required"),
                           ])
    end

    context "AssessmentProceedingTypeSummarizer" do
      it "calls AssessmentProceedingTypeSummarizer for each proceeding type code" do
        expect(Summarizers::AssessmentProceedingTypeSummarizer)
          .to receive(:call)
                .with(proceeding_type_code: "DA003", receives_qualifying_benefit: false, receives_asylum_support: false,
                      gross_income_assessment_result: "eligible", disposable_income_result: "ineligible",
                      capital_assessment_result: "contribution_required").and_call_original
        expect(Summarizers::AssessmentProceedingTypeSummarizer)
          .to receive(:call).with(proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false,
                                  gross_income_assessment_result: "eligible", disposable_income_result: "ineligible",
                                  capital_assessment_result: "contribution_required").and_call_original
        summarizer
      end
    end

    context "result summarizer" do
      before do
        # create :assessment_eligibility, assessment:, proceeding_type_code: "DA003", assessment_result: "eligible"
        # create :assessment_eligibility, assessment:, proceeding_type_code: "SE014", assessment_result: "ineligible"

        allow(Summarizers::AssessmentProceedingTypeSummarizer)
          .to receive(:call)
                .with(proceeding_type_code: "DA003",
                      receives_qualifying_benefit: false, receives_asylum_support: false,
                      gross_income_assessment_result: "eligible",
                      capital_assessment_result: "contribution_required",
                      disposable_income_result: "ineligible").and_return("eligible")
        allow(Summarizers::AssessmentProceedingTypeSummarizer)
          .to receive(:call)
                .with(proceeding_type_code: "SE014", receives_qualifying_benefit: false, receives_asylum_support: false,
                      gross_income_assessment_result: "eligible", disposable_income_result: "ineligible",
                      capital_assessment_result: "contribution_required").and_return("ineligible")
      end

      it "calls the Results summarizer to return the assessment result" do
        expect(Utilities::ResultSummarizer).to receive(:call).with(%w[eligible ineligible]).and_call_original
        expect(summarizer.assessment_result).to eq "partially_eligible"
      end
    end
  end
end
