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
        instance_double(CalculationOutput,
                        gross_income_subtotals: instance_double(GrossIncome::Subtotals,
                                                                combined_monthly_gross_income: 0,
                                                                applicant_gross_income_subtotals:
                                                                  PersonGrossIncomeSubtotals.new(
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
                                                                eligibilities: []),
                        assessment_result: "eligible",
                        income_contribution: 0,
                        disposable_income_eligibilities: [],
                        combined_total_disposable_income: 0,
                        combined_total_outgoings_and_allowances: 0,
                        applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
                        partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
                        capital_subtotals: Capital::Unassessed.new(applicant_capitals: instance_double(CapitalsData, vehicles: [], properties: []),
                                                                   partner_capitals: nil,
                                                                   proceeding_types: assessment.proceeding_types,
                                                                   level_of_help: assessment.level_of_help,
                                                                   submission_date: assessment.submission_date))
      end

      describe "#as_json" do
        subject(:decorator) do
          described_class.new(assessment: assessment.reload, calculation_output:,
                              applicant:,
                              partner:).as_json
        end
        let(:applicant) { build(:person_data, details: build(:applicant)) }
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
          let(:partner) { build(:person_data, details: build(:applicant)) }

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
