require "rails_helper"

module Decorators
  module V6
    RSpec.describe GrossIncomeDecorator do
      let(:assessment) { build(:assessment) }

      let(:irregular_income_payments) do
        [build(:unspecified_source_payment, amount: 423.35),
         build(:student_loan_payment, frequency: "monthly", amount: 250)]
      end

      let(:subtotals) do
        PersonGrossIncomeSubtotals.new(
          irregular_income_payments:,
          state_benefits:,
          employment_income_subtotals: instance_double(EmploymentIncomeSubtotals,
                                                       payment_based_employments: [
                                                         OpenStruct.new(employment_name: first_employment.name, employment_payments: first_employment.employment_payments),
                                                         OpenStruct.new(employment_name: employment2.name, employment_payments: employment2.employment_payments),
                                                       ],
                                                       self_employment_details: [],
                                                       employment_details: []),
          regular_income_categories: [
            GrossIncomeCategorySubtotals.new(category: :benefits, bank: 1322.6, cash: 0, regular: 0),
            GrossIncomeCategorySubtotals.new(category: :maintenance_in, bank: 200, cash: 150, regular: 0),
            GrossIncomeCategorySubtotals.new(category: :friends_or_family, bank: 0, cash: 50, regular: 0),
            GrossIncomeCategorySubtotals.new(category: :property_or_lodger, bank: 250, cash: 0, regular: 0),
            GrossIncomeCategorySubtotals.new(category: :pension, bank: 0, cash: 0, regular: 0),
          ],
        )
      end

      let(:first_employment) { build :employment, :with_monthly_payments, submission_date: assessment.submission_date }
      let(:employment2) { build :employment, :with_monthly_payments, submission_date: assessment.submission_date }
      let(:universal_credit) { create :state_benefit_type, :universal_credit }
      let(:child_benefit) { create :state_benefit_type, :child_benefit }

      let(:expected_results) do
        {
          employment_income: [
            {
              name: first_employment.name,
              payments: [
                {
                  date: Time.zone.today.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 1.month.ago.to_date.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 2.months.ago.to_date.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
              ],
            },
            {
              name: employment2.name,
              payments: [
                {
                  date: Time.zone.today.strftime("%Y-%m-%d"),
                  benefits_in_kind: 23.87,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 1.month.ago.to_date.strftime("%Y-%m-%d"),
                  benefits_in_kind: 23.87,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 2.months.ago.to_date.strftime("%Y-%m-%d"),
                  benefits_in_kind: 23.87,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 878.87,
                },
              ],
            },
          ],
          irregular_income: {
            monthly_equivalents:
              {
                student_loan: 250.0,
                unspecified_source: 423.35,
              },
          },
          state_benefits: {
            monthly_equivalents: {
              all_sources: 1322.6,
              cash_transactions: 0.0,
              bank_transactions: [
                {
                  name: "Universal Credit",
                  monthly_value: 979.33,
                  excluded_from_income_assessment: false,
                },
                {
                  name: "Child Benefit",
                  monthly_value: 343.27,
                  excluded_from_income_assessment: false,
                },
              ],
            },
          },
          other_income: {
            monthly_equivalents: {
              all_sources: {
                friends_or_family: 50.0,
                maintenance_in: 350.0,
                property_or_lodger: 250.0,
                pension: 0.0,
              },
              bank_transactions: {
                friends_or_family: 0.0,
                maintenance_in: 200.0,
                property_or_lodger: 250.0,
                pension: 0.0,
              },
              cash_transactions: {
                friends_or_family: 50.0,
                maintenance_in: 150.0,
                property_or_lodger: 0.0,
                pension: 0.0,
              },
            },
          },
        }
      end

      describe "#as_json", :calls_bank_holiday do
        let(:state_benefits) do
          [
            build(:state_benefit, state_benefit_name: universal_credit.name, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 979.33)),
            build(:state_benefit, state_benefit_name: child_benefit.name, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 343.27)),
          ]
        end

        subject(:decorator) do
          described_class.new([first_employment, employment2], subtotals).as_json
        end

        it "returns the expected structure" do
          expect(decorator).to match(expected_results)
        end
      end
    end
  end
end
