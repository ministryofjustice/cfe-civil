require "rails_helper"

module Decorators
  module V6
    RSpec.describe ApplicantGrossIncomeResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:eligibility_records) do
        ptc_results.map do |ptc, thresh_and_result|
          threshold, result = thresh_and_result
          Eligibility::GrossIncome.new upper_threshold: threshold, lower_threshold: nil, assessment_result: result, proceeding_type: ptc
        end
      end
      let(:ptc_results) do
        {
          build(:proceeding_type, ccms_code: "DA002", client_involvement_type: "A") => [unlimited, "eligible"],
          build(:proceeding_type, ccms_code: "DA003", client_involvement_type: "A") => [unlimited, "eligible"],
          build(:proceeding_type, ccms_code: "SE013", client_involvement_type: "A") => [8_000, "ineligible"],
        }
      end
      let(:ptcs) { ptc_results.keys }
      let(:assessment) { create :assessment, proceedings: [%w[DA002 A], %w[DA003 A], %w[SE013 A]] }
      let(:summary) do
        create :gross_income_summary,
               unspecified_source_payments: build_list(:unspecified_source_payment, 1, amount: 16_615.40),
               assessment:
      end
      let(:expected_hash) do
        {
          total_gross_income: 16_615.40,
          proceeding_types: [
            {
              ccms_code: "DA002",
              client_involvement_type: "A",
              upper_threshold: 999_999_999_999.0,
              lower_threshold: 0.0,
              result: "eligible",
            },
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              upper_threshold: 999_999_999_999.0,
              lower_threshold: 0.0,
              result: "eligible",
            },
            {
              ccms_code: "SE013",
              client_involvement_type: "A",
              upper_threshold: 8_000.0,
              lower_threshold: 0.0,
              result: "ineligible",
            },
          ],
          combined_total_gross_income: 0.0,
        }
      end

      subject(:decorator) do
        described_class.new(proceeding_types: ptc_results.keys,
                            gross_income_subtotals: instance_double(
                              GrossIncome::Subtotals,
                              eligibilities: eligibility_records,
                              applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.new(gross_income_summary: summary,
                                                                                               employment_income_subtotals: EmploymentIncomeSubtotals.blank,
                                                                                               regular_income_categories: [],
                                                                                               state_benefits: []),
                              combined_monthly_gross_income: 0,
                            ))
      end

      it "generates the expected hash" do
        expect(decorator.as_json).to eq expected_hash
      end
    end
  end
end
