require "rails_helper"

module Workflows
  RSpec.describe MainWorkflow do
    let(:proceeding_types) do
      [
        build(:proceeding_type, ccms_code: "DA003", client_involvement_type: "A"),
        build(:proceeding_type, ccms_code: "SE013", client_involvement_type: "I"),
      ]
    end
    let(:bank_holiday_response) { %w[2015-01-01 2015-04-03 2015-04-06] }
    let(:assessment) do
      create :assessment
    end
    let(:calculation_output) do
      instance_double(CalculationOutput,
                      gross_income_subtotals: GrossIncome::Unassessed.new(submission_date: assessment.submission_date,
                                                                          level_of_help: assessment.level_of_help),
                      applicant_disposable_income_subtotals: instance_double(PersonDisposableIncomeSubtotals, child_care_bank: 0),
                      capital_subtotals: instance_double(Capital::Subtotals,
                                                         summarized_assessment_result: :eligible,
                                                         combined_assessed_capital: 0))
    end
    let(:non_passported_result) { instance_double(WorkflowResult, calculation_output:, remarks: []) }
    let(:person_blank) { nil }

    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(bank_holiday_response)
    end

    context "applicant is passported" do
      let(:applicant) { build(:applicant, receives_qualifying_benefit: true) }

      context "without partner" do
        subject(:workflow_call) do
          described_class.without_partner(submission_date: assessment.submission_date,
                                          level_of_help: assessment.level_of_help,
                                          proceeding_types:,
                                          applicant: build(:person_data, details: applicant))
        end

        it "calls PassportedWorkflow" do
          allow(PassportedWorkflow).to receive(:without_partner)
            .with(capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                  non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                  date_of_birth: applicant.date_of_birth,
                  submission_date: assessment.submission_date,
                  level_of_help: assessment.level_of_help).and_return(calculation_output)
          workflow_call
        end
      end

      context "with partner" do
        let(:partner) { build(:applicant) }

        subject(:workflow_call) do
          described_class.with_partner(submission_date: assessment.submission_date, level_of_help: assessment.level_of_help,
                                       proceeding_types:,
                                       applicant: build(:person_data, details: applicant),
                                       partner: build(:person_data, details: partner))
        end

        it "calls PassportedWorkflow" do
          expect(PassportedWorkflow).to receive(:with_partner).with(capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                                                                    non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                                                                    partner_capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [],
                                                                                                            non_liquid_capital_items: [], main_home: {}, additional_properties: []),
                                                                    partner_date_of_birth: partner.date_of_birth,
                                                                    date_of_birth: applicant.date_of_birth,
                                                                    level_of_help: assessment.level_of_help,
                                                                    submission_date: assessment.submission_date).and_call_original
          workflow_call
        end
      end
    end

    context "applicant is not passported" do
      let(:applicant) { build(:applicant, :without_qualifying_benefits) }

      subject(:workflow_call) do
        described_class.without_partner(submission_date: assessment.submission_date, level_of_help: assessment.level_of_help,
                                        proceeding_types:,
                                        applicant: build(:person_data, details: applicant))
      end

      it "calls NonPassportedWorkflow" do
        allow(NonPassportedWorkflow).to receive(:without_partner).and_return(non_passported_result)
        workflow_call
      end
    end

    context "version 6" do
      let(:assessment) do
        create :assessment
      end
      let(:applicant) { build :applicant, :without_qualifying_benefits }

      subject(:workflow_call) do
        described_class.without_partner(submission_date: assessment.submission_date, level_of_help: assessment.level_of_help,
                                        proceeding_types:,
                                        applicant: build(:person_data, details: applicant))
      end

      context "with proceeding types" do
        it "Populates proceeding types with thresholds" do
          allow(NonPassportedWorkflow).to receive(:without_partner).and_return(non_passported_result)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(employments: [],
                                                                       lower_capital_threshold: 3000,
                                                                       child_care_bank: 0,
                                                                       state_benefits: [],
                                                                       liquid_capital_items: [],
                                                                       outgoings: [],
                                                                       other_income_payments: [],
                                                                       cash_transactions: [],
                                                                       regular_transactions: [],
                                                                       assessed_capital: 0,
                                                                       submission_date: assessment.submission_date).and_call_original

          workflow_call
        end

        it "creates the eligibility records" do
          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:certificated).with(proceeding_types:,
                                                                                            submission_date: assessment.submission_date)
          allow(NonPassportedWorkflow).to receive(:without_partner).and_return(non_passported_result)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(employments: [],
                                                                       lower_capital_threshold: 3000,
                                                                       child_care_bank: 0,
                                                                       liquid_capital_items: [],
                                                                       state_benefits: [],
                                                                       outgoings: [],
                                                                       other_income_payments: [],
                                                                       cash_transactions: [],
                                                                       regular_transactions: [],
                                                                       assessed_capital: 0,
                                                                       submission_date: assessment.submission_date).and_call_original

          workflow_call
        end
      end
    end
  end
end
