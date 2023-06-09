require "rails_helper"

module Creators
  RSpec.describe EligibilitiesCreator do
    before do
      described_class.call(assessment:, client_dependants:, partner_dependants:)
    end

    describe "#call" do
      context "with no children" do
        let(:assessment) { create :assessment, :with_everything }
        let(:client_dependants) { [] }
        let(:partner_dependants) { [] }

        it "creates an upper threshold" do
          expect(assessment.applicant_gross_income_summary.eligibilities.map(&:upper_threshold)).to eq([2657.0])
        end
      end

      context "with 5 children" do
        let(:assessment) { create(:assessment, :with_everything) }
        let(:client_dependants) { build_list(:dependant, 2, :child_relative, submission_date: assessment.submission_date) }
        let(:partner_dependants) { build_list(:dependant, 3, :child_relative, submission_date: assessment.submission_date) }

        it "creates an uplifted upper threshold" do
          expect(assessment.applicant_gross_income_summary.eligibilities.map(&:upper_threshold)).to eq([2879.0])
        end
      end
    end
  end
end
