require "rails_helper"

module Decorators
  module V6
    RSpec.describe AssessmentDecorator do
      let(:assessment) do
        create :assessment,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               :with_capital_summary,
               :with_eligibilities
      end
      let(:calculation_output) do
        CalculationOutput.new(
          gross_income_subtotals: GrossIncomeSubtotals.new(
            self_employments: [],
            partner_self_employments: [],
            applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.new(
              employment_income_subtotals: EmploymentIncomeSubtotals.blank,
              gross_income_summary: assessment.applicant_gross_income_summary,
              regular_income_categories: CFEConstants::VALID_INCOME_CATEGORIES.map do |category|
                GrossIncomeCategorySubtotals.new(category: category.to_sym, bank: 0, cash: 0, regular: 0)
              end,
            ),
            partner_gross_income_subtotals: PersonGrossIncomeSubtotals.new(
              employment_income_subtotals: EmploymentIncomeSubtotals.blank,
              gross_income_summary: assessment.applicant_gross_income_summary,
              regular_income_categories: CFEConstants::VALID_INCOME_CATEGORIES.map do |category|
                GrossIncomeCategorySubtotals.new(category: category.to_sym, bank: 0, cash: 0, regular: 0)
              end,
            ),
          ),
          capital_subtotals: CapitalSubtotals.unassessed(applicant: instance_double(PersonData,
                                                                                    capitals_data: instance_double(CapitalsData, vehicles: [])),
                                                         partner: nil, applicant_properties: [], partner_properties: []),
        )
      end

      describe "#as_json" do
        subject(:decorator) do
          described_class.new(assessment: assessment.reload, calculation_output:,
                              applicant: build(:person_data, details: build(:applicant)),
                              partner:).as_json
        end
        let(:partner) { nil }

        it "has the required keys in the returned hash" do
          expected_keys = %i[
            id
            client_reference_id
            submission_date
            level_of_help
            applicant
            gross_income
            disposable_income
            capital
            remarks
          ]
          expect(decorator[:assessment].keys).to match_array expected_keys
        end

        it "calls the decorators for associated records" do
          allow(::Decorators::V6::ApplicantDecorator).to receive(:new).and_return(instance_double("ad", as_json: nil))
          allow(::Decorators::V6::GrossIncomeDecorator).to receive(:new).and_return(instance_double("gisd", as_json: nil))
          allow(::Decorators::V6::DisposableIncomeDecorator).to receive(:new).and_return(instance_double("disd", as_json: nil))
          allow(::Decorators::V6::CapitalDecorator).to receive(:new).and_return(instance_double("csd", as_json: nil))
          allow(::Decorators::V6::RemarksDecorator).to receive(:new).and_return(instance_double("rmk", as_json: nil))
          allow(::Decorators::V6::ResultSummaryDecorator).to receive(:new).and_return(instance_double("rsd", as_json: nil))
          decorator
        end

        context "with partner" do
          let(:partner) { build(:applicant) }

          before do
            create(:partner_capital_summary, assessment:)
            create(:partner_gross_income_summary, assessment:)
            create(:partner_disposable_income_summary, assessment:)
          end

          it "includes partner information" do
            expect(decorator[:assessment][:partner_gross_income]).to be_present
            expect(decorator[:assessment][:partner_disposable_income]).to be_present
            expect(decorator[:assessment][:partner_capital]).to be_present
            expect(decorator[:result_summary][:partner_gross_income]).to be_present
            expect(decorator[:result_summary][:partner_disposable_income]).to be_present
            expect(decorator[:result_summary][:partner_capital]).to be_present
          end

          it "has the required keys in the returned hash" do
            expected_keys = %i[
              id
              client_reference_id
              submission_date
              level_of_help
              applicant
              gross_income
              disposable_income
              capital
              remarks
              partner_gross_income
              partner_disposable_income
              partner_capital
            ]
            expect(decorator[:assessment].keys).to match_array expected_keys
          end
        end
      end
    end
  end
end
