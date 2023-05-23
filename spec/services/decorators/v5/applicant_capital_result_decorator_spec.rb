require "rails_helper"

module Decorators
  module V5
    RSpec.describe ApplicantCapitalResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:assessment) { create :assessment, proceedings: pr_hash }
      let(:pt_results) do
        {
          DA003: [3000, unlimited, "eligible"],
          SE014: [3000, 8000, "ineligible"],
        }
      end
      let(:pr_hash) { [%w[DA003 A], %w[SE014 Z]] }
      let(:summary) do
        create :capital_summary, assessment:
      end

      let(:subtotals) do
        instance_double(PersonCapitalSubtotals,
                        total_vehicle: 3500,
                        total_capital: 860_908.45,
                        subject_matter_of_dispute_disregard: 8454,
                        assessed_capital: 845_454.45,
                        total_disputed_capital: 4567,
                        total_non_disputed_capital: 5678,
                        total_capital_with_smod: 855_454.45,
                        total_liquid: 9_355.23,
                        total_non_liquid: 12_553.22,
                        total_property: 835_500,
                        total_mortgage_allowance: 750_000,
                        pensioner_disregard_applied: 10_000,
                        pensioner_capital_disregard: 12_000,
                        disputed_non_property_disregard: 5_454,
                        disputed_property_disregard: 3_000)
      end
      let(:capital_contribution) { 0 }
      let(:combined_assessed_capital) { 12_000 }

      let(:expected_result) do
        {
          pensioner_disregard_applied: 10_000.0,
          total_liquid: 9_355.23,
          total_non_liquid: 12_553.22,
          total_vehicle: 3500.0,
          total_property: 835_500.0,
          total_mortgage_allowance: 750_000.0,
          total_capital: 860_908.45,
          subject_matter_of_dispute_disregard: 8454.0,
          assessed_capital: 845_454.45,
          total_capital_with_smod: 855_454.45,
          disputed_non_property_disregard: 5_454,
          proceeding_types: [
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              lower_threshold: 3_000.0,
              upper_threshold: 999_999_999_999.0,
              result: "eligible",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "Z",
              lower_threshold: 3_000.0,
              upper_threshold: 8_000.0,
              result: "ineligible",
            },
          ],
          combined_assessed_capital: 12_000.0,
          combined_disputed_capital: 9134,
          combined_non_disputed_capital: 11_356,
          pensioner_capital_disregard: 12_000,
          capital_contribution: 0.0,
        }
      end

      before do
        pt_results.each do |ptc, details|
          lower_threshold, upper_threshold, result = details
          create :capital_eligibility,
                 capital_summary: summary,
                 proceeding_type_code: ptc,
                 lower_threshold:,
                 upper_threshold:,
                 assessment_result: result
        end
      end

      subject(:decorator) do
        described_class.new(summary: assessment.applicant_capital_summary,
                            applicant_capital_subtotals: subtotals,
                            partner_capital_subtotals: subtotals,
                            capital_contribution:,
                            combined_assessed_capital:).as_json
      end

      describe "#as_json" do
        it "returns the expected structure" do
          expect(decorator).to eq expected_result
        end
      end
    end
  end
end
