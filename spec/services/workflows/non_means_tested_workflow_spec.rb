require "rails_helper"

module Workflows
  RSpec.describe NonMeansTestedWorkflow do
    let(:proceeding_types) do
      [
        build(:proceeding_type, ccms_code: "DA003", client_involvement_type: "A"),
        build(:proceeding_type, ccms_code: "SE013", client_involvement_type: "I"),
      ]
    end
    let(:assessment) do
      build :assessment
    end

    context "applicant is asylum_supported" do
      let(:applicant) { build(:applicant, receives_asylum_support: true) }

      describe "#non_means_tested?" do
        context "without a immigration proceeding type" do
          it "is means tested" do
            expect(described_class.non_means_tested?(submission_date: assessment.submission_date,
                                                     level_of_help: assessment.level_of_help,
                                                     controlled_legal_representation: assessment.controlled_legal_representation,
                                                     not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
                                                     applicant_under_18_years_old: applicant.under_18_years_old?(assessment.submission_date),
                                                     receives_asylum_support: applicant.receives_asylum_support,
                                                     proceeding_type_codes: proceeding_types.map(&:ccms_code))).to be(false)
          end
        end

        context "before MTR changes, require proceeding type check" do
          let(:proceeding_types) { build_list(:proceeding_type, 1, ccms_code: "IM030", client_involvement_type: "A") }

          it "is not means tested" do
            expect(described_class.non_means_tested?(submission_date: assessment.submission_date,
                                                     level_of_help: assessment.level_of_help,
                                                     controlled_legal_representation: assessment.controlled_legal_representation,
                                                     not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
                                                     applicant_under_18_years_old: applicant.under_18_years_old?(assessment.submission_date),
                                                     receives_asylum_support: applicant.receives_asylum_support,
                                                     proceeding_type_codes: proceeding_types.map(&:ccms_code))).to be(true)
          end
        end

        context "after MTR changes, skip proceeding type check" do
          around do |example|
            travel_to Date.new(2525, 4, 20)
            example.run
            travel_back
          end

          it "is not means tested" do
            expect(described_class.non_means_tested?(submission_date: assessment.submission_date,
                                                     level_of_help: assessment.level_of_help,
                                                     controlled_legal_representation: assessment.controlled_legal_representation,
                                                     not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
                                                     applicant_under_18_years_old: applicant.under_18_years_old?(assessment.submission_date),
                                                     receives_asylum_support: applicant.receives_asylum_support,
                                                     proceeding_type_codes: proceeding_types.map(&:ccms_code))).to be(true)
          end
        end
      end
    end
  end
end
