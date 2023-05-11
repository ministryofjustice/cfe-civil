require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) do
      create :assessment, :with_capital_summary, :with_disposable_income_summary,
             :with_gross_income_summary,
             submission_date: Date.new(2022, 6, 7),
             applicant:, proceedings: proceeding_types.map { |p| [p, "A"] }, level_of_help:
    end

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :gross_income_eligibility, gross_income_summary: assessment.gross_income_summary, proceeding_type_code: ptc
        create :disposable_income_eligibility, disposable_income_summary: assessment.disposable_income_summary,
                                               lower_threshold: 500,
                                               proceeding_type_code: ptc
      end
      Creators::CapitalEligibilityCreator.call(assessment)
    end

    describe "#call", :calls_bank_holiday do
      let(:proceeding_types) { %w[SE003] }

      subject(:assessment_result) do
        assessment.reload
        described_class.call(assessment, self_employed)
        Assessors::MainAssessor.call(assessment)
        assessment.assessment_result
      end

      before do
        assessment.proceeding_type_codes.each do |ptc|
          create(:assessment_eligibility, assessment:, proceeding_type_code: ptc)
        end
      end

      context "with controlled work" do
        let(:level_of_help) { "controlled" }

        describe "self employed" do
          let(:applicant) { build :applicant }
          let(:calculation_output) do
            assessment.reload
            described_class.call(assessment, self_employed).tap do |_output|
              Assessors::MainAssessor.call(assessment)
            end
          end
          let(:employment_income_subtotals) { calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals }

          describe "frequencies" do
            let(:self_employed) { [OpenStruct.new(income: SelfEmploymentIncome.new(tax: 200, national_insurance: 100, gross: 1000, frequency:))] }

            context "monthly" do
              let(:frequency) { "monthly" }

              it "returns employment figures" do
                expect(
                  {
                    gross_employment_income: employment_income_subtotals.gross_employment_income,
                    national_insurance: employment_income_subtotals.national_insurance,
                    tax: employment_income_subtotals.tax,
                    employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                  }.transform_values(&:to_f),
                ).to eq(gross_employment_income: 1000.0,
                        national_insurance: -100.0,
                        tax: -200.0,
                        employment_income_deductions: -300.0)
              end
            end

            context "weekly" do
              let(:frequency) { "weekly" }

              it "returns weekly figures" do
                expect(
                  {
                    gross_employment_income: employment_income_subtotals.gross_employment_income,
                    national_insurance: employment_income_subtotals.national_insurance,
                    tax: employment_income_subtotals.tax,
                    employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                  }.transform_values(&:to_f),
                ).to eq(gross_employment_income: 4333.33,
                        national_insurance: -433.33,
                        tax: -866.67,
                        employment_income_deductions: -1300.00)
              end
            end

            context "2 weekly" do
              let(:frequency) { "two_weekly" }

              it "returns 2 weekly figures" do
                expect(
                  {
                    gross_employment_income: employment_income_subtotals.gross_employment_income,
                    national_insurance: employment_income_subtotals.national_insurance,
                    tax: employment_income_subtotals.tax,
                    employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                  }.transform_values(&:to_f),
                ).to eq(gross_employment_income: 2166.67,
                        national_insurance: -216.67,
                        tax: -433.33,
                        employment_income_deductions: -650.00)
              end
            end

            context "4 weekly" do
              let(:frequency) { "four_weekly" }

              it "returns 4 weekly figures" do
                expect(
                  {
                    gross_employment_income: employment_income_subtotals.gross_employment_income,
                    national_insurance: employment_income_subtotals.national_insurance,
                    tax: employment_income_subtotals.tax,
                    employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                  }.transform_values(&:to_f),
                ).to eq(gross_employment_income: 1083.33,
                        national_insurance: -108.33,
                        tax: -216.67,
                        employment_income_deductions: -325.00)
              end
            end

            context "3 monthly" do
              let(:frequency) { "three_monthly" }

              it "returns 3 monthly figures" do
                expect(
                  {
                    gross_employment_income: employment_income_subtotals.gross_employment_income,
                    national_insurance: employment_income_subtotals.national_insurance,
                    tax: employment_income_subtotals.tax,
                    employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                  }.transform_values(&:to_f),
                ).to eq(gross_employment_income: 333.33,
                        national_insurance: -33.33,
                        tax: -66.67,
                        employment_income_deductions: -100.00)
              end
            end
          end

          context "with 2 self employments" do
            let(:self_employed) do
              [
                OpenStruct.new(income: SelfEmploymentIncome.new(tax: 220, national_insurance: 20, gross: 520, frequency: "monthly")),
                OpenStruct.new(income: SelfEmploymentIncome.new(tax: 420, national_insurance: 40, gross: 720, frequency: "monthly", is_employment: true)),
              ]
            end

            it "returns employment figures" do
              expect(
                {
                  fixed_employment_allowance: employment_income_subtotals.fixed_employment_allowance,
                  gross_employment_income: employment_income_subtotals.gross_employment_income,
                  national_insurance: employment_income_subtotals.national_insurance,
                  tax: employment_income_subtotals.tax,
                  employment_income_deductions: employment_income_subtotals.employment_income_deductions,
                }.transform_values(&:to_f),
              ).to eq(fixed_employment_allowance: -45.0,
                      gross_employment_income: 1240.0,
                      national_insurance: -60.0,
                      tax: -640.0,
                      employment_income_deductions: -700.0)
            end
          end
        end

        describe "capital thresholds for controlled" do
          let(:self_employed) { [] }
          let(:applicant) { build :applicant, :under_pensionable_age }

          before do
            create(:property, :additional_property, capital_summary: assessment.capital_summary,
                                                    value: property_value, outstanding_mortgage: 0, percentage_owned: 100)
          end

          context "with 8k capital" do
            let(:property_value) { 8_000 }

            it "is eligible" do
              expect(assessment_result).to eq("eligible")
            end
          end

          context "with a first-tier immigration case" do
            let(:proceeding_types) { [CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE] }

            context "with 8k capital" do
              let(:property_value) { 8_000 }

              it "is ineligible" do
                expect(assessment_result).to eq("ineligible")
              end
            end

            context "with 3k capital" do
              let(:property_value) { 3_000 }

              it "is eligible" do
                expect(assessment_result).to eq("eligible")
              end
            end
          end
        end
      end

      context "with certificated work" do
        let(:level_of_help) { "certificated" }
        let(:self_employed) { [] }

        context "with capital" do
          before do
            create(:property, :additional_property, capital_summary: assessment.capital_summary,
                                                    value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)
          end

          context "without partner" do
            let(:applicant) { build :applicant, :under_pensionable_age }

            it "is not eligible" do
              expect(assessment_result).to eq("ineligible")
            end
          end

          context "with pensionable partner" do
            let(:applicant) { build :applicant, :under_pensionable_age }

            before do
              create(:partner, :over_pensionable_age, assessment:)
            end

            it "is eligible" do
              expect(assessment_result).to eq("eligible")
            end
          end

          context "when both pensioners" do
            let(:applicant) { build :applicant, :over_pensionable_age }

            before do
              create(:partner, :over_pensionable_age, assessment:)
              create(:property, :additional_property, capital_summary: assessment.partner_capital_summary,
                                                      value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)
            end

            it "doesnt double-count" do
              expect(assessment_result).to eq("ineligible")
            end
          end
        end

        context "without capital" do
          let(:applicant) { build :applicant, :over_pensionable_age, employed: }

          context "with childcare costs (and at least 1 dependent child)" do
            let(:salary) { 19_000 }

            before do
              create(:child_care_transaction_category,
                     gross_income_summary: assessment.gross_income_summary,
                     cash_transactions: build_list(:cash_transaction, 1, amount: 800))
              create(:dependant, :under15, assessment:)
            end

            context "when employed" do
              let(:employed) { true }

              before do
                create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
              end

              it "is eligible" do
                expect(assessment_result).to eq("eligible")
              end
            end

            context "when unemployed with partner" do
              let(:employed) { false }

              context "with partner employment" do
                before do
                  create(:partner, assessment:, employed: true)
                  create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
                end

                it "is eligible" do
                  expect(assessment_result).to eq("eligible")
                end
              end

              context "with partner student loan" do
                before do
                  create(:partner, assessment:, employed: false)
                  create(:student_loan_payment, gross_income_summary: assessment.reload.partner_gross_income_summary)
                end

                it "is eligible" do
                  expect(assessment_result).to eq("eligible")
                end
              end
            end
          end

          context "with housing costs" do
            let(:employed) { true }

            before do
              create(:employment, :with_monthly_payments, assessment:,
                                                          gross_monthly_income: 3_000)
              create(:housing_cost, amount: 1000,
                                    gross_income_summary: assessment.gross_income_summary)
            end

            it "is not eligible due to housing cost cap" do
              expect(assessment_result).to eq("contribution_required")
            end

            context "with partner" do
              before do
                create(:partner, assessment:)
                create(:gross_income_summary, assessment:, type: "PartnerGrossIncomeSummary")
                create(:disposable_income_summary, assessment:, type: "PartnerDisposableIncomeSummary")
              end

              it "is eligible due to cap being removed" do
                expect(assessment_result).to eq("eligible")
              end
            end
          end

          context "with employment" do
            let(:salary) { 15_300 }

            context "when unemployed" do
              let(:employed) { false }

              it "is below the theshold and thus eligible" do
                expect(assessment_result).to eq("eligible")
              end

              context "with an employed partner" do
                before do
                  create(:partner, assessment:, employed: true)
                  create(:partner_employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
                end

                it "is eligible due to partner allowance" do
                  expect(assessment_result).to eq("eligible")
                end
              end
            end

            context "when employed" do
              let(:employed) { true }

              before do
                create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
              end

              it "is not eligible due to income" do
                expect(assessment_result).to eq("contribution_required")
              end
            end
          end
        end
      end
    end
  end
end
