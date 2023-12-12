require "rails_helper"

module Creators
  RSpec.describe CapitalEligibilityCreator do
    let(:assessment) do
      create :assessment,
             level_of_help:,
             proceedings: [%w[DA002 A], %w[SE013 Z], %w[IM030 A], %w[IA031 A]]
    end

    describe "lower_capital_threshold" do
      let(:level_of_help) { "certificated" }

      context "with many proceeding types" do
        let(:lower_threshold) do
          described_class.lower_capital_threshold(proceeding_types: assessment.proceeding_types,
                                                  level_of_help: assessment.level_of_help,
                                                  submission_date: assessment.submission_date)
        end

        it "returns the lowest based on proceeding types" do
          expect(lower_threshold).to eq(3000)
        end
      end

      context "with no proceeding types" do
        let(:lower_threshold) do
          described_class.lower_capital_threshold(proceeding_types: [],
                                                  level_of_help: assessment.level_of_help,
                                                  submission_date: assessment.submission_date)
        end

        it "returns the default threshold" do
          expect(lower_threshold).to eq(3000)
        end
      end
    end

    describe "#call" do
      let(:summary) { assessment.applicant_capital_summary }
      let(:creator) do
        described_class.call(proceeding_types: assessment.proceeding_types,
                             level_of_help: assessment.level_of_help,
                             assessed_capital: 0,
                             submission_date: assessment.submission_date).index_by { |p| p.proceeding_type.ccms_code }
      end
      let(:eligibilities) { assessment.applicant_capital_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }

      before do
        Utilities::ProceedingTypeThresholdPopulator.certificated proceeding_types:,
                                                                 submission_date: assessment.submission_date
      end

      context "without MTR" do
        around do |example|
          travel_to Date.new(2022, 4, 20)
          example.run
          travel_back
        end

        context "for certificated work" do
          let(:level_of_help) { "certificated" }

          it "creates a capital eligibility record for each proceeding type" do
            expect(creator.values.map(&:proceeding_type)).to match_array(proceeding_types)
          end

          it "creates eligibility record with correct waived thresholds" do
            pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
            elig = creator.fetch("DA002")
            expect(elig.upper_threshold).to eq pt.capital_upper_threshold
            expect(elig.lower_threshold).to eq 3_000.0
          end

          it "creates eligibility record with correct un-waived thresholds" do
            pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
            elig = creator.fetch("SE013")
            expect(elig.upper_threshold).to eq pt.capital_upper_threshold
            expect(elig.lower_threshold).to eq 3_000.0
          end

          it "creates records for asylum proceedings" do
            elig = creator.fetch("IA031")
            expect(elig.upper_threshold).to eq 8_000.0
            expect(elig.lower_threshold).to eq 8_000.0
          end

          it "creates records for immigration proceedings" do
            elig = creator.fetch("IM030")
            expect(elig.upper_threshold).to eq 3_000.0
            expect(elig.lower_threshold).to eq 3_000.0
          end
        end

        context "for controlled work" do
          let(:level_of_help) { "controlled" }

          it "uses controlled lower threshold" do
            pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
            elig = creator.fetch("SE013")
            expect(elig.upper_threshold).to eq pt.capital_upper_threshold
            expect(elig.lower_threshold).to eq 8_000.0
          end
        end
      end

      context "with MTR rules" do
        around do |example|
          travel_to Date.new(2525, 4, 20)
          example.run
          travel_back
        end

        context "certificated work" do
          let(:level_of_help) { "certificated" }

          it "uses the new thresholds for simples cases" do
            expect(creator.fetch("SE013")).to have_attributes(upper_threshold: 11_000, lower_threshold: 7000)
          end

          it "uses the same thresholds for asylum cases" do
            expect(creator.fetch("IA031")).to have_attributes(upper_threshold: 11_000, lower_threshold: 7000)
          end

          it "uses the same thresholds for immigratioon cases" do
            expect(creator.fetch("IM030")).to have_attributes(upper_threshold: 11_000, lower_threshold: 7000)
          end
        end

        context "controlled work" do
          let(:level_of_help) { "controlled" }

          it "uses the new upper threshold for both" do
            expect(creator.fetch("SE013")).to have_attributes(upper_threshold: 11_000, lower_threshold: 11_000)
          end
        end
      end
    end
  end
end
