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
      described_class.call(assessment.applicant_gross_income_summary,
                           dependants,
                           assessment.proceeding_types,
                           assessment.submission_date)
    end

    context "version 6" do
      let(:assessment) { create :assessment, :with_gross_income_summary, proceedings: [%w[DA002 A], %w[SE013 Z]] }
      let(:eligibilities) { assessment.applicant_gross_income_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }
      let(:dependants) { [] }

      it "creates a capital eligibility record for each proceeding type" do
        creator
        expect(eligibilities.size).to eq 2
        expect(eligibilities.map(&:proceeding_type_code)).to match_array(proceeding_types.map(&:ccms_code))
      end

      it "creates eligibility record with correct waived thresholds" do
        creator
        pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
        elig = eligibilities.find_by!(proceeding_type_code: "DA002")
        expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
        expect(elig.lower_threshold).to be_nil
      end

      context "no dependants" do
        let(:dependants) { [] }

        it "creates eligibility record with correct un-waived thresholds" do
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
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
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold
          expect(elig.lower_threshold).to be_nil
        end
      end

      context "six children" do
        let(:expected_uplift) { 222 * 2 }
        let(:dependants) { build_list :dependant, 6, :child_relative, submission_date: assessment.submission_date }

        it "creates a record with the uplifted threshold" do
          creator
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = eligibilities.find_by!(proceeding_type_code: "SE013")
          expect(elig.upper_threshold).to eq pt.gross_income_upper_threshold + expected_uplift
          expect(elig.assessment_result).to eq "pending"
        end
      end
    end
  end
end
