require "rails_helper"

module Calculators
  RSpec.describe ChildcareEligibilityCalculator do
    describe "#call" do
      let(:dependants) { [] }
      let(:submission_date) { 1.year.ago }

      let(:applicant_gross_income_subtotals) do
        instance_double(PersonGrossIncomeSubtotals, employment_income_subtotals: instance_double(EmploymentIncomeSubtotals, entitles_child_care_allowance?: true))
      end

      let(:partner_gross_income_subtotals) do
        instance_double(PersonGrossIncomeSubtotals, employment_income_subtotals: instance_double(EmploymentIncomeSubtotals, entitles_child_care_allowance?: true))
      end

      context "without partner" do
        subject(:calculated_result) { described_class.call(applicant_incomes: [applicant_gross_income_subtotals].compact, dependants:, submission_date:) }

        context "with no dependants, an employed applicant and no partner" do
          it "returns false" do
            expect(calculated_result).to be false
          end
        end

        context "with child dependants, an employed applicant and no partner" do
          let(:dependants) { [instance_double(Dependant, becomes_16_on: submission_date + 1.year)] }

          it "returns true" do
            expect(calculated_result).to be true
          end
        end

        context "with child dependants, a student applicant and no partner" do
          let(:dependants) { [instance_double(Dependant, becomes_16_on: submission_date + 1.year)] }
          let(:applicant_gross_income_subtotals) do
            instance_double(PersonGrossIncomeSubtotals, is_student?: true, employment_income_subtotals: instance_double(EmploymentIncomeSubtotals, entitles_child_care_allowance?: false))
          end

          it "returns true" do
            expect(calculated_result).to be true
          end
        end

        context "with adult dependants, an employed applicant and no partner" do
          let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date - 1.year)] }

          it "returns false" do
            expect(calculated_result).to be false
          end
        end
      end

      context "with partner" do
        subject(:calculated_result) { described_class.call(applicant_incomes: [applicant_gross_income_subtotals, partner_gross_income_subtotals].compact, dependants:, submission_date:) }

        context "with child dependants, an employed applicant and an employed partner" do
          let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date + 1.year)] }
          let(:partner_gross_income_subtotals) do
            instance_double(PersonGrossIncomeSubtotals, is_student?: false, employment_income_subtotals: instance_double(EmploymentIncomeSubtotals, entitles_child_care_allowance?: true))
          end

          it "returns true" do
            expect(calculated_result).to be true
          end
        end

        context "with child dependants, an employed applicant and an unemployed partner" do
          let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date + 1.year)] }
          let(:partner_gross_income_subtotals) do
            instance_double(PersonGrossIncomeSubtotals, is_student?: false, employment_income_subtotals: instance_double(EmploymentIncomeSubtotals, entitles_child_care_allowance?: false))
          end

          it "returns false" do
            expect(calculated_result).to be false
          end
        end
      end
    end
  end
end
