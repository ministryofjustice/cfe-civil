require "rails_helper"

module Creators
  RSpec.describe DisposableIncomeEligibilityCreator do
    let(:summary) { assessment.applicant_disposable_income_summary }

    around do |example|
      travel_to Date.new(2022, 4, 20)
      example.run
      travel_back
    end

    context "version 6" do
      let(:eligibilities) { assessment.applicant_disposable_income_summary.eligibilities }
      let(:proceeding_types) { assessment.proceeding_types }
      let(:proceeding_hash) { [%w[DA002 A], %w[SE013 Z], %w[IM030 A]] }

      let(:creator) do
        described_class.call(proceeding_types: assessment.proceeding_types, submission_date: assessment.submission_date,
                             level_of_help: assessment.level_of_help, total_disposable_income: 0)
      end

      context "for certificated work" do
        let(:assessment) { create :assessment, :with_disposable_income_summary, proceedings: proceeding_hash }

        it "creates a capital eligibility record for each proceeding type" do
          expect(creator.map(&:proceeding_type)).to match_array(proceeding_types)
        end

        it "creates eligibilty record with correct waived thresholds" do
          pt = proceeding_types.find_by!(ccms_code: "DA002", client_involvement_type: "A")
          elig = creator.detect { |p| p.proceeding_type.ccms_code == "DA002" }
          expect(elig.upper_threshold).to eq pt.disposable_income_upper_threshold
          expect(elig.lower_threshold).to eq 315.0
        end

        it "creates eligibilty record with correct un-waived thresholds" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = creator.detect { |p| p.proceeding_type.ccms_code == "SE013" }
          expect(elig.upper_threshold).to eq pt.disposable_income_upper_threshold
          expect(elig.lower_threshold).to eq 315.0
        end

        it "creates records for immigration proceedings" do
          elig = creator.detect { |p| p.proceeding_type.ccms_code == "IM030" }
          expect(elig.upper_threshold).to eq 733.0
          expect(elig.lower_threshold).to eq 733.0
        end
      end

      context "for controlled work" do
        let(:assessment) do
          create :assessment,
                 :with_disposable_income_summary,
                 proceedings: proceeding_hash,
                 level_of_help: "controlled"
        end

        it "uses controlled lower threshold" do
          pt = proceeding_types.find_by!(ccms_code: "SE013", client_involvement_type: "Z")
          elig = creator.detect { |p| p.proceeding_type.ccms_code == "SE013" }
          expect(elig.upper_threshold).to eq pt.disposable_income_upper_threshold
          expect(elig.lower_threshold).to eq 733.0
        end
      end
    end
  end
end