require "rails_helper"

module Workflows
  RSpec.describe MainWorkflow do
    let(:proceedings_hash) { [%w[DA003 A], %w[SE013 I]] }
    let(:bank_holiday_response) { %w[2015-01-01 2015-04-03 2015-04-06] }
    let(:assessment) do
      create :assessment,
             :with_everything,
             proceedings: proceedings_hash
    end
    let(:calculation_output) do
      instance_double(CalculationOutput,
                      disposable_income_eligibilities: [
                        Eligibility::DisposableIncome.new(proceeding_type: assessment.proceeding_types.first, assessment_result: "eligible",
                                                          upper_threshold: 27, lower_threshold: 14),
                        Eligibility::DisposableIncome.new(proceeding_type: assessment.proceeding_types.last, assessment_result: "eligible",
                                                          upper_threshold: 27, lower_threshold: 14),
                      ],
                      gross_income_subtotals: GrossIncome::Unassessed.new(assessment.proceeding_types),
                      applicant_disposable_income_subtotals: instance_double(PersonDisposableIncomeSubtotals, child_care_bank: 0),
                      capital_subtotals: instance_double(Capital::Subtotals,
                                                         combined_assessed_capital: 0,
                                                         summarized_assessment_result: :eligible,
                                                         eligibilities: [
                                                           Eligibility::Capital.new(proceeding_type: assessment.proceeding_types.first,
                                                                                    assessment_result: "contribution_required",
                                                                                    upper_threshold: 6000, lower_threshold: 3000),
                                                         ]))
    end
    let(:non_passported_result) { instance_double(NonPassportedWorkflow::Result, calculation_output:, remarks: []) }
    let(:person_blank) { nil }

    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(bank_holiday_response)
    end

    context "applicant is asylum_supported" do
      let(:applicant) { build(:applicant, receives_asylum_support: true) }

      it "calls normal workflows by default" do
        allow(PassportedWorkflow).to receive(:call).and_return(calculation_output)
        described_class.call(assessment:,
                             applicant: build(:person_data, details: applicant),
                             partner: nil)
      end

      context "for immigration/asylum proceeding types" do
        let(:proceedings_hash) { [%w[IM030 A]] }

        it "does not call a workflow" do
          expect(PassportedWorkflow).not_to receive(:call)
          expect(NonPassportedWorkflow).not_to receive(:call)
          described_class.call(assessment:,
                               applicant: build(:person_data, details: applicant),
                               partner: nil)
        end
      end
    end

    context "applicant is passported" do
      let(:applicant) { build(:applicant, receives_qualifying_benefit: true) }

      context "without partner" do
        subject(:workflow_call) do
          described_class.call(assessment:,
                               applicant: build(:person_data, details: applicant),
                               partner: nil)
        end

        it "calls PassportedWorkflow" do
          allow(Summarizers::MainSummarizer).to receive(:call)
          allow(PassportedWorkflow).to receive(:call).with(proceeding_types: assessment.proceeding_types,
                                                           capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                                                           non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                                                           date_of_birth: applicant.date_of_birth,
                                                           submission_date: assessment.submission_date,
                                                           level_of_help: assessment.level_of_help,
                                                           receives_asylum_support: false).and_return(calculation_output)
          workflow_call
        end

        it "calls MainSummarizer" do
          allow(PassportedWorkflow).to receive(:call).and_return(calculation_output)
          workflow_call
        end
      end

      context "with partner" do
        let(:partner) { build(:applicant) }

        subject(:workflow_call) do
          described_class.call(assessment:,
                               applicant: build(:person_data, details: applicant),
                               partner: build(:person_data, details: partner))
        end

        before do
          create(:partner_capital_summary, assessment:)
          create(:partner_gross_income_summary, assessment:)
          create(:partner_disposable_income_summary, assessment:)
        end

        it "calls PassportedWorkflow" do
          allow(Summarizers::MainSummarizer).to receive(:call).and_return(OpenStruct.new(assessment_result: :ineligible))
          expect(PassportedWorkflow).to receive(:partner).with(proceeding_types: assessment.proceeding_types,
                                                               capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                                                               non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                                                               partner_capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                                                                       non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                                                               partner_date_of_birth: partner.date_of_birth,
                                                               date_of_birth: applicant.date_of_birth,
                                                               level_of_help: assessment.level_of_help,
                                                               submission_date: assessment.submission_date,
                                                               receives_asylum_support: false).and_call_original
          workflow_call
        end
      end
    end

    context "applicant is not passported" do
      let(:applicant) { build(:applicant, :without_qualifying_benefits) }

      subject(:workflow_call) do
        described_class.call(assessment:,
                             applicant: build(:person_data, details: applicant),
                             partner: nil)
      end

      it "calls NonPassportedWorkflow" do
        allow(Summarizers::MainSummarizer).to receive(:call)
        allow(NonPassportedWorkflow).to receive(:call).and_return(non_passported_result)
        workflow_call
      end

      it "calls MainSummarizer" do
        allow(NonPassportedWorkflow).to receive(:call).and_return(non_passported_result)
        workflow_call
      end
    end

    context "version 6" do
      let(:assessment) do
        create :assessment,
               :with_capital_summary,
               :with_capital_summary,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               proceedings: proceedings_hash
      end
      let(:applicant) { build :applicant, :without_qualifying_benefits }

      subject(:workflow_call) do
        described_class.call(assessment:,
                             applicant: build(:person_data, details: applicant),
                             partner: nil)
      end

      context "with proceeding types" do
        it "Populates proceeding types with thresholds" do
          allow(NonPassportedWorkflow).to receive(:call).and_return(non_passported_result)
          allow(Summarizers::MainSummarizer).to receive(:call)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(employments: [],
                                                                       lower_capital_threshold: 3000,
                                                                       child_care_bank: 0,
                                                                       state_benefits: [],
                                                                       liquid_capital_items: [],
                                                                       outgoings: [],
                                                                       gross_income_summary: assessment.applicant_gross_income_summary,
                                                                       assessed_capital: 0).and_call_original

          workflow_call
        end

        it "creates the eligibility records" do
          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).and_return(non_passported_result)
          allow(Summarizers::MainSummarizer).to receive(:call)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(employments: [],
                                                                       lower_capital_threshold: 3000,
                                                                       child_care_bank: 0,
                                                                       liquid_capital_items: [],
                                                                       state_benefits: [],
                                                                       outgoings: [],
                                                                       gross_income_summary: assessment.applicant_gross_income_summary,
                                                                       assessed_capital: 0).and_call_original

          workflow_call
        end
      end
    end
  end
end
