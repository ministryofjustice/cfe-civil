require "rails_helper"

module Collators
  RSpec.describe DependantsAllowanceCollator do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }

    subject(:collator) do
      described_class.call(dependants: dependants.map { |x| DependantWrapper.new(dependant: x, submission_date: assessment.submission_date) },
                           submission_date: assessment.submission_date)
    end

    describe ".call" do
      context "no dependants" do
        let(:dependants) { [] }

        it "leaves the monthly dependants allowance as zero" do
          expect(collator).to have_attributes(under_16: 0.0, over_16: 0.0)
        end
      end

      context "with dependants" do
        let(:dependant1) { create :dependant, :under15, in_full_time_education: true, assessment: }
        let(:dependant2) { create :dependant, :over18, in_full_time_education: true, assessment: }
        let(:dependant3) { create :dependant, :aged16or17, in_full_time_education: true, assessment: }
        let(:dependants) { [dependant1, dependant2, dependant3] }

        it "updates the dependant records and returns the under_16s / over_16s grouped together" do
          expect(collator).to have_attributes(under_16: 338.9, over_16: 338.9 + 338.9)
          expect(dependants.map(&:reload).map(&:dependant_allowance))
            .to eq([338.9, 338.9, 338.9])
        end
      end
    end
  end
end
