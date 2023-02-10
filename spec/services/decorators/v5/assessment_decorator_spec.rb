require "rails_helper"

module Decorators
  module V5
    RSpec.describe AssessmentDecorator do
      let(:assessment) do
        create :assessment,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               :with_capital_summary,
               :with_applicant,
               :with_eligibilities
      end
      let(:calculation_output) do
        CalculationOutput.new(
          capital_subtotals: CapitalSubtotals.new(
            applicant_capital_subtotals: PersonCapitalSubtotals.new(total_vehicle: 0),
            partner_capital_subtotals: PersonCapitalSubtotals.new(total_vehicle: 0),
          ),
        )
      end

      describe "#as_json" do
        subject(:decorator) { described_class.new(assessment, calculation_output).as_json }

        it "has the required keys in the returned hash" do
          expected_keys = %i[
            id
            client_reference_id
            submission_date
            applicant
            gross_income
            partner_gross_income
            disposable_income
            partner_disposable_income
            capital
            partner_capital
            remarks
          ]
          expect(decorator.keys).to eq %i[version timestamp success result_summary assessment]
          expect(decorator[:assessment].keys).to eq expected_keys
        end

        it "calls the decorators for associated records" do
          allow(::Decorators::V5::ApplicantDecorator).to receive(:new).and_return(instance_double("ad", as_json: nil))
          allow(::Decorators::V5::GrossIncomeDecorator).to receive(:new).and_return(instance_double("gisd", as_json: nil))
          allow(::Decorators::V5::DisposableIncomeDecorator).to receive(:new).and_return(instance_double("disd", as_json: nil))
          allow(::Decorators::V5::CapitalDecorator).to receive(:new).and_return(instance_double("csd", as_json: nil))
          allow(::Decorators::V5::RemarksDecorator).to receive(:new).and_return(instance_double("rmk", as_json: nil))
          allow(::Decorators::V5::ResultSummaryDecorator).to receive(:new).and_return(instance_double("rsd", as_json: nil))
          decorator
        end

        it "includes partner information" do
          partner_financials_params = {
            partner: {
              employed: true,
              date_of_birth: 30.years.ago.to_date.to_s,
            },
          }
          Creators::PartnerFinancialsCreator.call(assessment_id: assessment.id, partner_financials_params:)
          expect(decorator[:assessment][:partner_gross_income]).to be_present
          expect(decorator[:assessment][:partner_disposable_income]).to be_present
          expect(decorator[:assessment][:partner_capital]).to be_present
          expect(decorator[:result_summary][:partner_gross_income]).to be_present
          expect(decorator[:result_summary][:partner_disposable_income]).to be_present
          expect(decorator[:result_summary][:partner_capital]).to be_present
        end
      end
    end
  end
end
