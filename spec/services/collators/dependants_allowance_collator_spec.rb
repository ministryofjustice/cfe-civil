require "rails_helper"

module Collators
  RSpec.describe DependantsAllowanceCollator do
    let(:submission_date) { Date.current }

    subject(:collator) do
      described_class.call(dependants: dependants.map do |x|
                                         DependantWrapper.new(dependant: x,
                                                              submission_date:)
                                       end,
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
        let(:dependant1) { build :dependant, :under15, in_full_time_education: true }
        let(:dependant2) { build :dependant, :over18, in_full_time_education: true }
        let(:dependant3) { build :dependant, :aged16or17, in_full_time_education: true }
        let(:dependants) { [dependant1, dependant2, dependant3] }

        it "returns the under_16s / over_16s grouped together" do
          expect(collator).to have_attributes(under_16: 338.9, over_16: 338.9 + 338.9)
        end
      end
    end
  end
end
