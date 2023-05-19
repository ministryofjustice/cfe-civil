require "rails_helper"

module Utilities
  RSpec.describe EmploymentIncomeVariationChecker do
    let(:employment) { create :employment }
    let(:payments) { amounts.map { |amount| Data.define(:gross_income_monthly_equiv).new(gross_income_monthly_equiv: amount) } }
    let(:result) { described_class.new(payments).below_threshold?(employment.assessment.submission_date) }

    context "no variance" do
      let(:amounts) { [2000.0, 2000.0, 2000.0, 2000.0] }

      it "is true" do
        expect(result).to be true
      end
    end

    context "variance less than £60" do
      let(:amounts) { [2000.0, 1941.0, 1966.0, 1996.0] }

      it "is  true" do
        expect(result).to be true
      end
    end

    context "variance exactly £60" do
      let(:amounts) { [2000.0, 1940.0, 1966.0, 1996.0] }

      it "is false" do
        expect(result).to be false
      end
    end

    context "variance greater £60" do
      let(:amounts) { [2000.0, 1922.0, 1966.0, 1996.0] }

      it "is false" do
        expect(result).to be false
      end
    end
  end
end
