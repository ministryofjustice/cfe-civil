require "rails_helper"

module Creators
  RSpec.describe GrossIncomeEligibilityCreator, :calls_lfa do
    let(:summary) { assessment.applicant_gross_income_summary }
    let(:assessment) { create :assessment, :with_gross_income_summary, proceedings: [%w[DA002 A], %w[SE013 Z]] }
    let(:proceeding_types) { assessment.proceeding_types }
    let(:submission_date) { assessment.submission_date.to_date }

    before do
      Utilities::ProceedingTypeThresholdPopulator.certificated(proceeding_types: assessment.proceeding_types,
                                                               submission_date: assessment.submission_date)
    end

    subject(:creator) do
      described_class.call(dependants:,
                           proceeding_types:,
                           submission_date:, total_gross_income: 0, level_of_help:).index_by { |h| h.proceeding_type.ccms_code }
    end

    context "without MTR" do
      let(:level_of_help) { assessment.level_of_help }

      around do |example|
        travel_to Date.new(2021, 4, 20)
        example.run
        travel_back
      end

      context "no dependants" do
        let(:dependants) { [] }

        it "creates eligibility record with correct waived thresholds" do
          expect(creator.fetch("DA002"))
            .to have_attributes(
              upper_threshold: 999_999_999_999,
              lower_threshold: 0.0,
            )
        end

        it "creates eligibility record with correct un-waived thresholds" do
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
            )
        end
      end

      context "two children" do
        let(:dependants) do
          build_list(:dependant, 2, :child_relative, submission_date: assessment.submission_date) +
            build_list(:dependant, 4, :adult_relative, submission_date: assessment.submission_date)
        end

        it "creates eligibility record with no dependant uplift on threshold" do
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
            )
        end
      end

      context "six children" do
        let(:expected_uplift) { 222 * 2 }
        let(:dependants) { build_list :dependant, 6, :child_relative, submission_date: assessment.submission_date }

        it "creates a record with the uplifted threshold" do
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: 2657.0 + expected_uplift,
              lower_threshold: 0.0,
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

      context "with certificated work" do
        let(:level_of_help) { "certificated" }

        let(:dependants) do
          build_list(:dependant, 2, :child_relative, date_of_birth: submission_date - 12.years, submission_date:) +
            build_list(:dependant, 4, :adult_relative, date_of_birth: submission_date - 15.years, submission_date:)
        end

        it "creates a record with the uplifted threshold" do
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: 2912.50 * 3.6,
              lower_threshold: 0.0,
            )
        end

        it "does not uplift the waived threshold" do
          expect(creator.fetch("DA002"))
            .to have_attributes(
              upper_threshold: 999_999_999_999,
              lower_threshold: 0.0,
            )
        end
      end

      context "with controlled work" do
        let(:level_of_help) { "controlled" }
        let(:dependants) { [] }

        it "has the correct lower threshold" do
          expect(creator.fetch("SE013"))
            .to have_attributes(
              upper_threshold: 2912.50,
              lower_threshold: 946.0,
            )
        end
      end
    end
  end
end
