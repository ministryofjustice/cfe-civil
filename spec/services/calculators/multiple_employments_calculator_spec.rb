require "rails_helper"

module Calculators
  RSpec.describe MultipleEmploymentsCalculator, :vcr do
    let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }

    before do
      create_list :employment, 2, assessment:
    end

    it "sets gross employment income to zero" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).gross_employment_income).to eq 0
    end

    it "sets benefits in kind to zero" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).benefits_in_kind).to eq 0
    end

    it "sets employment income deductions to zero" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).employment_income_deductions).to eq 0
    end

    it "sets tax to zero" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).tax).to eq 0
    end

    it "sets national insurance to zero" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).national_insurance).to eq 0
    end

    it "sets fixed employment allowance to 45" do
      expect(described_class.call(submission_date: assessment.submission_date,
                                  employments: assessment.employments).fixed_employment_allowance).to eq(-45)
    end
  end
end
