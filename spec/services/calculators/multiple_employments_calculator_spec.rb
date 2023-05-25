require "rails_helper"

module Calculators
  RSpec.describe MultipleEmploymentsCalculator, :vcr do
    let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }

    it "sets all items to zero apart from allowance" do
      expect(described_class.call(assessment.submission_date))
        .to have_attributes(
          gross_employment_income: 0.0,
          benefits_in_kind: 0.0,
          tax: 0.0,
          national_insurance: 0.0,
          fixed_employment_allowance: -45.0,
        )
    end
  end
end
