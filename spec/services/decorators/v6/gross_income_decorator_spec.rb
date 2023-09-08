require "rails_helper"

module Decorators
  module V6
    RSpec.describe GrossIncomeDecorator do
      before do
        create :assessment
        create_list(:employment, 2, :with_monthly_payments, assessment:)
      end

      let(:assessment) { Assessment.last }

      let(:summary) do
        create :gross_income_summary,
               assessment:,
               unspecified_source_payments: build_list(:unspecified_source_payment, 1, amount: 423.35),
               student_loan_payments: build_list(:student_loan_payment, 1, frequency: "monthly", amount: 250)
      end

      let(:subtotals) do
        PersonGrossIncomeSubtotals.new(
          gross_income_summary: summary,
          employment_income_subtotals: instance_double(EmploymentIncomeSubtotals,
                                                       payment_based_employments: [
                                                         OpenStruct.new(employment_name: employment1.name, employment_payments: employment1.employment_payments),
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

      let(:employment1) { assessment.employments.order(:name).first }
      let(:employment2) { assessment.employments.order(:name).last }
      let(:universal_credit) { create :state_benefit_type, :universal_credit }
      let(:child_benefit) { create :state_benefit_type, :child_benefit }

      let(:expected_results) do
        {
          employment_income: [
            {
              name: employment1.name,
              payments: [
                {
                  date: Time.zone.today.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 1.month.ago.to_date.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 2.months.ago.to_date.strftime("%Y-%m-%d"),
                  gross: 1500.0,
                  benefits_in_kind: 23.87,
                  tax: -495.0,
                  national_insurance: -150.0,
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
                  net_employment_income: 878.87,
                },
                {
                  date: 1.month.ago.to_date.strftime("%Y-%m-%d"),
                  benefits_in_kind: 23.87,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 878.87,
                },
                {
                  date: 2.months.ago.to_date.strftime("%Y-%m-%d"),
                  benefits_in_kind: 23.87,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
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
        before do
          create(:state_benefit, :with_monthly_payments, state_benefit_type: universal_credit, gross_income_summary: summary, payment_amount: 979.33)
          create(:state_benefit, :with_monthly_payments, state_benefit_type: child_benefit, gross_income_summary: summary, payment_amount: 343.27)
        end

        subject(:decorator) do
          described_class.new(assessment.applicant_gross_income_summary,
                              assessment.employments, subtotals).as_json
        end

        it "returns the expected structure" do
          expect(decorator).to match(expected_results)
        end
      end
    end
  end
end
