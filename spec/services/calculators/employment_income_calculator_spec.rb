require "rails_helper"

module Calculators
  RSpec.describe EmploymentIncomeCalculator, :vcr do
    let(:assessment) { build :assessment }
    let(:employment1) { OpenStruct.new(entitles_employment_allowance?: entitles_employment_allowance) }
    let(:gross) { BigDecimal(rand(2022.35...3096.52), 2) }
    let(:tax) { (gross * 0.23).round(2) * -1 }
    let(:ni_cont) { (gross * 0.052).round(2) * -1 }
    let(:benefits_in_kind) { BigDecimal(rand(-77.0...-25.0), 2) }
    let(:month1) { Date.parse("2021-04-30") }
    let(:month2) { Date.parse("2021-05-30") }
    let(:month3) { Date.parse("2021-06-30") }
    let(:dates) { [month1, month2, month3] }
    let(:expected_gross_income) { gross + benefits_in_kind + gross + benefits_in_kind }
    let(:expected_deductions) { tax + ni_cont + tax + ni_cont }
    let(:expected_benefits_in_kind) { benefits_in_kind + benefits_in_kind }
    let(:expected_tax) { tax + tax }
    let(:expected_national_insurance) { ni_cont + ni_cont }
    let(:entitles_employment_allowance) { true }

    describe "fixed income allowance" do
      context "at least one employment record exists" do
        it "adds the fixed employment allowance from the threshold files" do
          expect(described_class.call(submission_date: assessment.submission_date,
                                      employment: employment1).result.fixed_employment_allowance).to eq(-45)
        end

        context "if applicant is not in work" do
          let(:entitles_employment_allowance) { false }

          it "ignores fixed employment allowance" do
            expect(described_class.call(submission_date: assessment.submission_date,
                                        employment: employment1).result.fixed_employment_allowance).to eq(0)
          end
        end
      end
    end
  end
end
