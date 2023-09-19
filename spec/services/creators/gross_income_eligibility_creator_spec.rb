require "rails_helper"

module Creators
  RSpec.describe GrossIncomeEligibilityCreator do
    let(:summary) { assessment.applicant_gross_income_summary }
    let(:assessment) { create :assessment, :with_gross_income_summary, proceedings: [%w[DA002 A], %w[SE013 Z]] }
    let(:proceeding_types) { assessment.proceeding_types }
    let(:submission_date) { assessment.submission_date.to_date }

    before do
      ::Utilities::ProceedingTypeThresholdPopulator.call(assessment)
    end

    subject(:creator) do
      described_class.call(dependants:,
                           proceeding_types:,
                           submission_date:, total_gross_income: 0).index_by { |h| h.proceeding_type.ccms_code }
    end

    context "without MTR" do
      around do |example|
        travel_to Date.new(2021, 4, 20)
        example.run
        travel_back
      end

      context "no dependants" do
        let(:dependants) { [] }

        it "creates eligibility record with correct waived thresholds" do
          pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
          expect(creator.fetch("DA002"))
            .to have_attributes(
              upper_threshold: pt.gross_income_upper_threshold,
              lower_threshold: nil,
            )
        end

        it "creates eligibility record with correct un-waived thresholds" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: pt.gross_income_upper_threshold,
              lower_threshold: nil,
            )
        end
      end

      context "two children" do
        let(:dependants) do
          build_list(:dependant, 2, :child_relative, submission_date: assessment.submission_date) +
            build_list(:dependant, 4, :adult_relative, submission_date: assessment.submission_date)
        end

        it "creates eligibility record with no dependant uplift on threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: pt.gross_income_upper_threshold,
              lower_threshold: nil,
            )
        end
      end

      context "six children" do
        let(:expected_uplift) { 222 * 2 }
        let(:dependants) { build_list :dependant, 6, :child_relative, submission_date: assessment.submission_date }

        it "creates a record with the uplifted threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: pt.gross_income_upper_threshold + expected_uplift,
              lower_threshold: nil,
            )
        end
      end
    end

    context "with MTR" do
      around do |example|
        travel_to Date.new(2525, 4, 20)
        example.run
        travel_back
      end

      let(:dependants) do
        build_list(:dependant, 2, :child_relative, date_of_birth: submission_date - 12.years, submission_date:) +
          build_list(:dependant, 4, :adult_relative, date_of_birth: submission_date - 15.years, submission_date:)
      end

      it "creates a record with the uplifted threshold" do
        proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
        expect(creator.fetch("SE013"))
          .to have_attributes(
            upper_threshold: 2912.50 * 3.6,
            lower_threshold: nil,
          )
      end
    end
  end
end
