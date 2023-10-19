require "rails_helper"

module Calculators
  RSpec.describe LoneParentAllowanceCalculator do
    context "post MTR" do
      let(:submission_date) { Date.new(2525, 4, 10) }

      it "calculates 70% of adult dependant allowance" do
        expect(described_class.call(dependants: build_list(:dependant, 1, :child_relative, submission_date:), submission_date:)).to eq(313.6)
      end
    end
  end
end
