require "rails_helper"

module Decorators
  module V6
    RSpec.describe ApplicantDisposableIncomeResultDecorator, :vcr do
      let(:unlimited) { 999_999_999_999.0 }
      let(:assessment) do
        create :assessment, :with_gross_income_summary, proceedings: proceeding_hash,
                                                        submission_date: Date.new(2022, 6, 6)
      end
      let(:summary) do
        create :disposable_income_summary,
               assessment:
      end
      let(:codes) { pt_results.keys }
      let(:pt_results) do
        {
          DA003: [315, unlimited, "contribution_required"],
          DA005: [315, unlimited, "contribution_required"],
          SE003: [315, 733, "ineligible"],
          SE014: [315, 733, "ineligible"],
        }
      end
      let(:proceeding_hash) { [%w[DA003 A], %w[DA005 A], %w[SE003 A], %w[SE014 A]] }
      let(:expected_result) do
        {
          dependant_allowance: 220.21,
          dependant_allowance_under_16: 28.34,
          dependant_allowance_over_16: 98.12,
          gross_housing_costs: 990.42,
          housing_benefit: 440.21,
          net_housing_costs: 550.21,
          maintenance_allowance: 330.21,
          total_outgoings_and_allowances: 660.21,
          total_disposable_income: 732.55,
          employment_income:
            {
              benefits_in_kind: 0.0,
              fixed_employment_deduction: -45.0,
              gross_income: 0.0,
              national_insurance: 0.0,
              prisoner_levy: 0.0,
              net_employment_income: -45.0,
              tax: 0.0,
            },
          income_contribution: 75.0,
          proceeding_types: [
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 999_999_999_999.0,
              result: "contribution_required",
            },
            {
              ccms_code: "DA005",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 999_999_999_999.0,
              result: "contribution_required",
            },
            {
              ccms_code: "SE003",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 733.0,
              result: "ineligible",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "A",
              lower_threshold: 315.0,
              upper_threshold: 733.0,
              result: "ineligible",
            },
          ],
          combined_total_disposable_income: 900.0,
          combined_total_outgoings_and_allowances: 400.32,
          partner_allowance: 191.41,
          lone_parent_allowance: 315.0,
        }
      end

      let(:employment_income_subtotals) do
        instance_double(EmploymentIncomeSubtotals,
                        benefits_in_kind: 0.0,
                        fixed_employment_allowance: -45.0,
                        net_employment_income: -45.0,
                        gross_employment_income: 0.0,
                        national_insurance: 0.0,
                        prisoner_levy: 0.0,
                        tax: 0.0)
      end

      let(:combined_outgoings) { 400.32 }
      let(:combined_disposable_income) { 900.0 }
      let(:income_contribution) { 75 }

      subject(:decorator) do
        described_class.new(summary, assessment.applicant_gross_income_summary, employment_income_subtotals,
                            income_contribution: 75,
                            disposable_income_subtotals: instance_double(PersonDisposableIncomeSubtotals,
                                                                         partner_allowance: 191.41,
                                                                         lone_parent_allowance: 315.0,
                                                                         dependant_allowance_under_16: 28.34,
                                                                         dependant_allowance_over_16: 98.12,
                                                                         dependant_allowance: 220.21,
                                                                         gross_housing_costs: 990.42,
                                                                         total_outgoings_and_allowances: 660.21,
                                                                         total_disposable_income: 732.55,
                                                                         housing_benefit: 440.21,
                                                                         net_housing_costs: 550.21,
                                                                         maintenance_out_all_sources: 330.21),
                            combined_total_disposable_income: 900.0,
                            eligibilities: Creators::DisposableIncomeEligibilityCreator.call(submission_date: assessment.submission_date,
                                                                                             level_of_help: assessment.level_of_help,
                                                                                             total_disposable_income: 900.0,
                                                                                             proceeding_types: assessment.proceeding_types),
                            combined_total_outgoings_and_allowances: 400.32).as_json
      end

      describe "#as_json" do
        it "returns the expected structure" do
          expect(decorator).to eq expected_result
        end
      end
    end
  end
end
