require "rails_helper"

module Workflows
  RSpec.describe ".call" do
    let(:proceedings_hash) { [%w[DA003 A], %w[SE013 I]] }
    let(:bank_holiday_response) { %w[2015-01-01 2015-04-03 2015-04-06] }
    let(:assessment) do
      create :assessment,
             :with_everything,
             proceedings: proceedings_hash,
             applicant:
    end
    let(:calculation_output) { instance_double(CalculationOutput, capital_subtotals: instance_double(CapitalSubtotals, combined_assessed_capital: 0)) }
    let(:person_blank) { PersonData.new(self_employments: [], vehicles: [], dependants: []) }

    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(bank_holiday_response)
    end

    context "applicant is asylum_supported" do
      let(:applicant) { create :applicant, receives_asylum_support: true }

      it "calls normal workflows by default" do
        allow(PassportedWorkflow).to receive(:call).and_return(calculation_output)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        MainWorkflow.call(assessment:, applicant: person_blank, partner: nil)
      end

      context "for immigration/asylum proceeding types" do
        let(:proceedings_hash) { [%w[IM030 A]] }

        it "does not call a workflow" do
          expect(PassportedWorkflow).not_to receive(:call)
          expect(NonPassportedWorkflow).not_to receive(:call)
          expect(Assessors::MainAssessor).to receive(:call).with(assessment)
          MainWorkflow.call(assessment:, applicant: person_blank, partner: nil)
        end
      end
    end

    context "applicant is passported" do
      let(:applicant) { create :applicant, :with_qualifying_benefits }

      subject(:workflow_call) do
        MainWorkflow.call(assessment:, applicant: person_blank, partner: nil)
      end

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(PassportedWorkflow).to receive(:call).with(assessment:, vehicles: [], partner_vehicles: []).and_return(calculation_output)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(PassportedWorkflow).to receive(:call).and_return(calculation_output)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "applicant is not passported" do
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) do
        MainWorkflow.call(assessment:, applicant: person_blank, partner: nil)
      end

      it "calls NonPassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(NonPassportedWorkflow).to receive(:call).and_return(calculation_output)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(NonPassportedWorkflow).to receive(:call).and_return(calculation_output)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
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
               :with_eligibilities,
               proceedings: proceedings_hash,
               version: "6",
               applicant:
      end
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) do
        MainWorkflow.call(assessment:, applicant: person_blank, partner: nil)
      end

      context "with proceeding types" do
        it "Populates proceeding types with thresholds" do
          expect(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)

          expect(Creators::EligibilitiesCreator).to receive(:call).with(assessment:, client_dependants: [], partner_dependants: [])
          allow(NonPassportedWorkflow).to receive(:call).and_return(calculation_output)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment:, employments: assessment.employments,
                                                                       lower_capital_threshold: 3000,
                                                                       disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                                       gross_income_summary: assessment.applicant_gross_income_summary,
                                                                       capital_summary: assessment.applicant_capital_summary,
                                                                       assessed_capital: 0)

          workflow_call
        end

        it "creates the eligibility records" do
          expect(Creators::EligibilitiesCreator).to receive(:call).with(assessment:, client_dependants: [], partner_dependants: [])

          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).and_return(calculation_output)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment:, employments: assessment.employments,
                                                                       lower_capital_threshold: 3000,
                                                                       disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                                       gross_income_summary: assessment.applicant_gross_income_summary,
                                                                       capital_summary: assessment.applicant_capital_summary,
                                                                       assessed_capital: 0)

          workflow_call
        end
      end
    end
  end
end
