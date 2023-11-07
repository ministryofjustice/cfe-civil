require "rails_helper"

module GrossIncome
  RSpec.describe Unassessed do
    describe "#eligibilities.lower_threshold" do
      let(:submission_date) { Date.new(2525, 4, 10) }
      let(:lower_thresholds) do
        described_class.new(level_of_help:, submission_date:)
                                              .eligibilities(build_list(:proceeding_type, 1)).map(&:lower_threshold)
      end

      context "when certificated" do
        let(:level_of_help) { "certificated" }

        it "succeeds" do
          expect(lower_thresholds).to eq([0.0])
        end
      end

      context "when controlled" do
        let(:level_of_help) { "controlled" }

        it "succeeds" do
          expect(lower_thresholds).to eq([946.0])
        end
      end
    end
  end
end
