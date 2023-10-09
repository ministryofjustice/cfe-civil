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

    subject(:summarizer) do
      described_class.call(proceeding_types: assessment.proceeding_types, receives_qualifying_benefit: false, receives_asylum_support: false,
                           gross_income_eligibilities: [
                             Eligibility::GrossIncome.new(proceeding_type: assessment.proceeding_types.first, assessment_result: "eligible", upper_threshold: 27),
                             Eligibility::GrossIncome.new(proceeding_type: assessment.proceeding_types.last, assessment_result: "eligible", upper_threshold: 27),
                           ],
                           disposable_income_eligibilities: [
                             Eligibility::DisposableIncome.new(proceeding_type: assessment.proceeding_types.first, assessment_result: "ineligible",
                                                               upper_threshold: 27, lower_threshold: 14),
                             Eligibility::DisposableIncome.new(proceeding_type: assessment.proceeding_types.last, assessment_result: "ineligible",
                                                               upper_threshold: 27, lower_threshold: 14),
                           ],
                           capital_eligibilities: [
                             Eligibility::Capital.new(proceeding_type: assessment.proceeding_types.first, assessment_result: "contribution_required",
                                                      upper_threshold: 27, lower_threshold: 14),
                             Eligibility::Capital.new(proceeding_type: assessment.proceeding_types.last, assessment_result: "contribution_required",
                                                      upper_threshold: 27, lower_threshold: 14),
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
