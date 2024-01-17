require "rails_helper"

module Workflows
  RSpec.describe NonMeansTestedWorkflow do
    let(:proceedings_hash) { [%w[DA003 A], %w[SE013 I]] }
    let(:assessment) do
      create :assessment,
             proceedings: proceedings_hash
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
                                                     proceeding_type_codes: assessment.proceeding_types.map(&:ccms_code))).to eq(false)
          end
        end

        context "before MTR changes, require proceeding type check" do
          let(:proceedings_hash) { [%w[IM030 A]] }

          it "is not means tested" do
            expect(described_class.non_means_tested?(submission_date: assessment.submission_date,
                                                     level_of_help: assessment.level_of_help,
                                                     controlled_legal_representation: assessment.controlled_legal_representation,
                                                     not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
                                                     applicant_under_18_years_old: applicant.under_18_years_old?(assessment.submission_date),
                                                     receives_asylum_support: applicant.receives_asylum_support,
                                                     proceeding_type_codes: assessment.proceeding_types.map(&:ccms_code))).to eq(true)
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
                                                     proceeding_type_codes: assessment.proceeding_types.map(&:ccms_code))).to eq(true)
          end
        end
      end
    end
  end
end
