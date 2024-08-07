require "rails_helper"

module Decorators
  module V6
    RSpec.describe AssessmentDecorator do
      let(:assessment) do
        build :assessment
      end
      let(:version) { "6" }
      let(:calculation_output) do
        instance_double(CalculationOutput,
                        submission_date: assessment.submission_date,
                        level_of_help: assessment.level_of_help,
                        gross_income_subtotals: instance_double(GrossIncome::Subtotals,
                                                                dependants: [],
                                                                combined_monthly_gross_income: 0,
                                                                applicant_gross_income_subtotals:
                                                                  PersonGrossIncomeSubtotals.new(
                                                                    state_benefits: [],
                                                                    employment_income_subtotals: EmploymentIncomeSubtotals.blank,
                                                                    irregular_income_payments: [],
                                                                    regular_income_categories: CFEConstants::VALID_INCOME_CATEGORIES.map do |category|
                                                                      GrossIncomeCategorySubtotals.new(category: category.to_sym, bank: 0, cash: 0, regular: 0)
                                                                    end,
                                                                  ),
                                                                partner_gross_income_subtotals: PersonGrossIncomeSubtotals.new(
                                                                  state_benefits: [],
                                                                  employment_income_subtotals: EmploymentIncomeSubtotals.blank,
                                                                  irregular_income_payments: [],
                                                                  regular_income_categories: CFEConstants::VALID_INCOME_CATEGORIES.map do |category|
                                                                    GrossIncomeCategorySubtotals.new(category: category.to_sym, bank: 0, cash: 0, regular: 0)
                                                                  end,
                                                                )),
                        income_contribution: 0,
                        combined_total_disposable_income: 0,
                        combined_total_outgoings_and_allowances: 0,
                        applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
                        partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
                        capital_subtotals: Capital::Unassessed.new(level_of_help: assessment.level_of_help,
                                                                   submission_date: assessment.submission_date))
      end
      let(:eligibility_result) do
        instance_double(EligibilityResults,
                        summarized_assessment_result: "eligible",
                        gross_eligibilities: [],
                        disposable_eligibilities: [],
                        capital_eligibilities: [],
                        assessment_results: [])
      end

      describe "#as_json" do
        let(:remarks) do
          { client: [RemarksData.new(:other_income_payment, :unknown_frequency, %w[abc def])] }
        end
        let(:applicant) do
          build(:person_data,
                details: build(:applicant))
        end
        let(:partner) { nil }

        subject(:decorator) do
          described_class.new(assessment:, calculation_output:,
                              applicant:,
                              partner:,
                              proceeding_types: [],
                              explicit_remarks: [],
                              eligibility_result:,
                              version:,
                              remarks:).as_json
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
          ]
          expect(decorator[:assessment].keys).to match_array expected_keys
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "calls the decorators for associated records" do
          allow(::Decorators::V6::ApplicantDecorator).to receive(:new).and_return(instance_double(ApplicantDecorator, as_json: nil))
          allow(::Decorators::V6::GrossIncomeDecorator).to receive(:new).and_return(instance_double(GrossIncomeDecorator, as_json: nil))
          allow(::Decorators::V6::DisposableIncomeDecorator).to receive(:new).and_return(instance_double(DisposableIncomeDecorator, as_json: nil))
          allow(::Decorators::V6::CapitalDecorator).to receive(:new).and_return(instance_double(CapitalDecorator, as_json: nil))
          allow(::Decorators::V6::RemarksDecorator).to receive(:new).and_return(instance_double(RemarksDecorator, as_json: nil))
          allow(::Decorators::V6::ResultSummaryDecorator).to receive(:new).and_return(instance_double(ResultSummaryDecorator, as_json: nil))
          decorator
        end
        # rubocop:enable RSpec/NoExpectationExample

        context "with partner" do
          let(:partner) do
            build(:person_data,
                  details: build(:applicant))
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
