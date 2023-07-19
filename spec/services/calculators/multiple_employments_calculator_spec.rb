require "rails_helper"

module Calculators
  RSpec.describe MultipleEmploymentsCalculator, :vcr do
    let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }
    let(:result) { described_class.call(assessment.submission_date) }

    it "sets all items to zero apart from allowance" do
      expect(result.employment).to be_entitles_employment_allowance
      expect(result.employment).not_to be_entitles_childcare_allowance
      expect(result.employment)
        .to have_attributes(
          monthly_gross_income: 0.0,
          monthly_benefits_in_kind: 0.0,
          monthly_tax: 0.0,
          monthly_national_insurance: 0.0,
        )
      expect(result.result)
        .to have_attributes(
          fixed_employment_allowance: -45.0,
        )
    end
  end
end
