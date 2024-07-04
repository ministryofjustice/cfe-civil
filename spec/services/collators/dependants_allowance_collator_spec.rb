require "rails_helper"

module Collators
  RSpec.describe DependantsAllowanceCollator do
    let(:submission_date) { Date.new(2024, 4, 4) }

    subject(:collator) do
      described_class.call(dependants:,
                           submission_date:)
    end

    describe ".call" do
      context "no dependants" do
        let(:dependants) { [] }

        it "leaves the monthly dependants allowance as zero" do
          expect(collator).to have_attributes(under_16: 0.0, over_16: 0.0)
        end
      end

      context "with dependants" do
        let(:dependants) do
          [build(:dependant, :under15, in_full_time_education: true, submission_date:),
           build(:dependant, :over18, in_full_time_education: true, submission_date:),
           build(:dependant, :aged16or17, in_full_time_education: true, submission_date:)]
        end

        it "returns the under_16s / over_16s grouped together" do
          expect(collator).to have_attributes(under_16: 338.9, over_16: 338.9 + 338.9)
        end
      end
    end
  end
end
