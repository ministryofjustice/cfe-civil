require "rails_helper"

module Creators
  RSpec.describe GrossIncomeEligibilityCreator do
    let(:summary) { assessment.applicant_gross_income_summary }

    around do |example|
      travel_to Date.new(2021, 4, 20)
      example.run
      travel_back
    end

    subject(:creator) do
      described_class.call(dependants:,
                           proceeding_types: assessment.proceeding_types,
                           submission_date: assessment.submission_date, total_gross_income: 0)
    end

    context "version 6" do
      let(:assessment) { create :assessment, :with_gross_income_summary, proceedings: [%w[DA002 A], %w[SE013 Z]] }
      let(:proceeding_types) { assessment.proceeding_types }
      let(:dependants) { [] }

      it "creates a capital eligibility record for each proceeding type" do
        expect(creator.map(&:proceeding_type)).to match_array(proceeding_types)
      end

      it "creates eligibility record with correct waived thresholds" do
        pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
        elig = creator.detect { _1.proceeding_type.ccms_code == "DA002" }
        expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
        expect(elig.lower_threshold).to be_nil
      end

      context "no dependants" do
        let(:dependants) { [] }

        it "creates eligibility record with correct un-waived thresholds" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = creator.detect { _1.proceeding_type.ccms_code == "SE013" }
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
          expect(elig.lower_threshold).to be_nil
        end
      end

      context "two children" do
        let(:dependants) do
          build_list(:dependant, 2, :child_relative, submission_date: assessment.submission_date) +
            build_list(:dependant, 4, :adult_relative, submission_date: assessment.submission_date)
        end

        it "creates eligibility record with no dependant uplift on threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = creator.detect { _1.proceeding_type.ccms_code == "SE013" }
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
          expect(elig.lower_threshold).to be_nil
        end
      end

      context "six children" do
        let(:expected_uplift) { 222 * 2 }
        let(:dependants) { build_list :dependant, 6, :child_relative, submission_date: assessment.submission_date }

        it "creates a record with the uplifted threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = creator.detect { _1.proceeding_type.ccms_code == "SE013" }
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold + expected_uplift
        end
      end
    end
  end
end
