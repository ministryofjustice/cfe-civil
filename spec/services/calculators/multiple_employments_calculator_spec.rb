require "rails_helper"

module Calculators
  RSpec.describe MultipleEmploymentsCalculator, :vcr do
    let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }
    let(:employments) { build_list(:employment, 2, :with_monthly_payments, submission_date: assessment.submission_date) }
    let(:result) do
      described_class.call(submission_date: assessment.submission_date,
                           employments: employments.map { OpenStruct.new(employment_name: _1.name) })
    end

    it "sets all items to zero apart from allowance" do
      expect(result.employments).to all have_attributes(
        monthly_gross_income: 0.0,
        monthly_benefits_in_kind: 0.0,
        monthly_tax: 0.0,
        monthly_national_insurance: 0.0,
        entitles_childcare_allowance?: true,
        entitles_employment_allowance?: true,
      )
      expect(result.result)
        .to have_attributes(
          fixed_employment_allowance: -45.0,
        )
    end
  end
end
