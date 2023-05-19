require "rails_helper"

module Creators
  RSpec.describe EligibilitiesCreator do
    before do
      described_class.call(assessment)
    end

    describe "#call" do
      context "with no children" do
        let(:assessment) { create :assessment, :with_everything }

        it "creates an upper threshold" do
          expect(assessment.gross_income_summary.eligibilities.map(&:upper_threshold)).to eq([2657.0])
        end
      end

      context "with 5 children" do
        let(:assessment) do
          create(:assessment, :with_everything,
                 client_dependants: build_list(:applicant_dependant, 2, :child_relative)).tap do |assessment|
            3.times do
              assessment.partner_dependants.create!(attributes_for(:dependant, :child_relative,
                                                                   submission_date: assessment.submission_date))
            end
          end
        end

        it "creates an uplifted upper threshold" do
          expect(assessment.gross_income_summary.eligibilities.map(&:upper_threshold)).to eq([2879.0])
        end
      end
    end
  end
end
