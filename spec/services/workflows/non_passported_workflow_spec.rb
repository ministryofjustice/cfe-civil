require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) do
      create :assessment, :with_capital_summary, :with_disposable_income_summary,
             :with_gross_income_summary,
             submission_date: Date.new(2022, 6, 7),
             proceedings: proceeding_types.map { |p| [p, "A"] }, level_of_help:
    end
    let(:partner) { nil }
    let(:applicant) { build(:applicant, employed:, dependants:) }
    let(:employments) { [] }
    let(:partner_employments) { [] }

    let(:main_home) { nil }
    let(:additional_properties) { [] }

    let(:partner_main_home) { nil }
    let(:partner_additional_properties) { [] }

    let(:gross_income_eligibilities) do
      assessment.proceeding_type_codes.map do |ptc|
        build :gross_income_eligibility, upper_threshold: gross_income_upper_threshold, proceeding_type_code: ptc
      end
    end

    let(:disposable_income_eligibilities) do
      assessment.proceeding_type_codes.each do |ptc|
        build :disposable_income_eligibility,
              upper_threshold: disposable_income_upper_threshold,
              lower_threshold: 500,
              proceeding_type_code: ptc
      end
    end

    context "vehicle collection output", :calls_bank_holiday do
      let(:disposable_income_upper_threshold) { 5000 }
      let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: 4000) }
      let(:applicant) { build :applicant }
      let(:proceeding_types) { %w[SE003] }
      let(:level_of_help) { "certificated" }
      let(:self_employments) do
        [OpenStruct.new(income: SelfEmploymentIncome.new(tax: 200, benefits_in_kind: 100,
                                                         national_insurance: 150, gross: 2900, frequency: "monthly"))]
      end

      let(:main_home) { nil }
      let(:additional_properties) { [] }
      let(:person_applicant) do
        build(:person_data, details: applicant,
                            capitals_data: build(:capitals_data, vehicles: build_list(:vehicle, 1), main_home: nil, additional_properties: []))
      end
      let(:partner_applicant) { person_applicant }

      subject(:calculation_output) do
        assessment.reload
        described_class.call(assessment:, applicant: person_applicant, partner: partner_applicant)
      end

      before do
        create(:partner_capital_summary, assessment:)
        create(:partner_gross_income_summary, assessment:)
        create(:partner_disposable_income_summary, assessment:)
      end

      context "with gross income exceeded" do
        let(:gross_income_upper_threshold) { 2000 }

        it "contains vehicles" do
          expect(calculation_output.capital_subtotals.applicant_capital_subtotals.vehicles.map(&:result).size).to eq(1)
          expect(calculation_output.capital_subtotals.applicant_capital_subtotals.vehicles.map(&:result).first).to have_attributes(assessed_value: 0, included_in_assessment: false)

          expect(calculation_output.capital_subtotals.partner_capital_subtotals.vehicles.map(&:result).size).to eq(1)
        end
      end

      context "with disposable income exceeded" do
        let(:gross_income_upper_threshold) { 5000 }
        let(:disposable_income_upper_threshold) { 2000 }

        it "contains vehicles" do
          expect(calculation_output.capital_subtotals.applicant_capital_subtotals.vehicles.map(&:result).size).to eq(1)
          expect(calculation_output.capital_subtotals.applicant_capital_subtotals.vehicles.map(&:result).first).to have_attributes(assessed_value: 0, included_in_assessment: false)

          expect(calculation_output.capital_subtotals.partner_capital_subtotals.vehicles.map(&:result).size).to eq(1)
        end
      end
    end

    describe "#call", :calls_bank_holiday do
      let(:gross_income_upper_threshold) { 9_999_999_999 }
      let(:disposable_income_upper_threshold) { 9_999_999_999 }
      let(:proceeding_types) { %w[SE003] }

      subject(:assessment_result) do
        assessment.reload
        co = described_class.call(assessment:,
                                  applicant: build(:person_data, details: applicant, dependants:, employments:, capitals_data: build(:capitals_data, main_home:, additional_properties:)),
                                  partner: partner.present? ? build(:person_data, details: partner, employments: partner_employments, capitals_data: build(:capitals_data, main_home: partner_main_home, additional_properties: partner_additional_properties)) : nil)
        Summarizers::MainSummarizer.call(proceeding_types: assessment.proceeding_types,
                                         receives_qualifying_benefit: false, receives_asylum_support: false,
                                         gross_income_eligibilities: co.gross_income_subtotals.eligibilities,
                                         disposable_income_eligibilities: co.disposable_income_eligibilities,
                                         capital_eligibilities: co.capital_subtotals.eligibilities)
        co.assessment_result
      end

      context "with controlled work" do
        let(:level_of_help) { "controlled" }
        let(:dependants) { [] }

        describe "self employed" do
          let(:applicant) { build :applicant }
          let(:calculation_output) do
            assessment.reload
            described_class.call(assessment:,
                                 applicant: build(:person_data, details: build(:applicant), self_employments:, capitals_data: build(:capitals_data, main_home:, additional_properties:)),
                                 partner:)
          end
          let(:employment_income_subtotals) { calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals }

          describe "frequencies" do
            let(:self_employments) do
              [OpenStruct.new(income: EmploymentIncome.new(tax: -200, benefits_in_kind: 100,
                                                           national_insurance: -150, gross: 900, frequency:))]
            end

            context "monthly" do
              let(:frequency) { "monthly" }

              it "returns employment figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 900.0,
                                      national_insurance: -150.0,
                                      benefits_in_kind: 100.0,
                                      tax: -200.0,
                                      employment_income_deductions: -350.0)
              end
            end

            context "annually" do
              let(:frequency) { "annually" }

              it "returns employment figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 75.0,
                                      national_insurance: -12.50,
                                      benefits_in_kind: 8.33,
                                      tax: -16.67)
              end
            end

            context "weekly" do
              let(:frequency) { "weekly" }

              it "returns weekly figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 3900.0,
                                      benefits_in_kind: 433.33,
                                      national_insurance: -650.0,
                                      tax: -866.67,
                                      employment_income_deductions: -1516.67)
              end
            end

            context "2 weekly" do
              let(:frequency) { "two_weekly" }

              it "returns 2 weekly figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 1950.0,
                                      national_insurance: -325.00,
                                      benefits_in_kind: 216.67,
                                      tax: -433.33,
                                      employment_income_deductions: -758.33)
              end
            end

            context "4 weekly" do
              let(:frequency) { "four_weekly" }

              it "returns 4 weekly figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 975.0,
                                      benefits_in_kind: 108.33,
                                      national_insurance: -162.50,
                                      tax: -216.67,
                                      employment_income_deductions: -379.17)
              end
            end

            context "3 monthly" do
              let(:frequency) { "three_monthly" }

              it "returns 3 monthly figures" do
                expect(employment_income_subtotals)
                  .to have_attributes(gross_employment_income: 300.0,
                                      national_insurance: -50.0,
                                      benefits_in_kind: 33.33,
                                      tax: -66.67,
                                      employment_income_deductions: -116.67)
              end
            end
          end

          context "with 2 self employments" do
            let(:self_employments) do
              [
                OpenStruct.new(income: SelfEmploymentIncome.new(tax: -220, national_insurance: -20, gross: 540, frequency: "monthly")),
                OpenStruct.new(income: EmploymentIncome.new(tax: -420, benefits_in_kind: 20, national_insurance: -40, gross: 720, frequency: "monthly")),
              ]
            end

            it "returns employment figures" do
              expect(employment_income_subtotals)
                .to have_attributes(fixed_employment_allowance: -45.0,
                                    gross_employment_income: 1260.0,
                                    benefits_in_kind: 20.0,
                                    national_insurance: -60.0,
                                    tax: -640.0,
                                    employment_income_deductions: -700.0)
            end
          end
        end

        describe "capital thresholds for controlled" do
          let(:self_employments) { [] }
          let(:applicant) { build :applicant, :pensionable_age_under_60 }

          let(:additional_properties) do
            [build(:property, :additional_property, value: property_value, outstanding_mortgage: 0, percentage_owned: 100)]
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
        let(:self_employments) { [] }

        context "with capital" do
          let(:dependants) { [] }

          let(:additional_properties) do
            [build(:property, :additional_property, value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)]
          end

          context "without partner" do
            let(:applicant) { build :applicant, :pensionable_age_under_60 }

            it "is not eligible" do
              expect(assessment_result).to eq("ineligible")
            end
          end

          context "with pensionable partner" do
            let(:applicant) { build :applicant, :pensionable_age_under_60 }
            let(:partner) { build :applicant, :pensionable_age_over_60 }

            before do
              create(:partner_capital_summary, assessment:)
              create(:partner_gross_income_summary, assessment:)
              create(:partner_disposable_income_summary, assessment:)
            end

            it "is eligible" do
              expect(assessment_result).to eq("eligible")
            end
          end

          context "when both pensioners" do
            let(:applicant) { build :applicant, :pensionable_age_over_60 }
            let(:partner) { build :applicant, :pensionable_age_over_60 }
            let(:partner_additional_properties) do
              [build(:property, :additional_property, value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)]
            end

            before do
              create(:partner_capital_summary, assessment:)
              create(:partner_gross_income_summary, assessment:)
              create(:partner_disposable_income_summary, assessment:)
            end

            it "doesnt double-count" do
              expect(assessment_result).to eq("ineligible")
            end
          end
        end

        context "without capital" do
          let(:applicant) { build :applicant, :pensionable_age_over_60, employed: }

          context "with childcare costs (and at least 1 dependent child)" do
            let(:salary) { 19_000 }
            let(:dependants) { build_list(:dependant, 1, :under15, submission_date: assessment.submission_date) }

            before do
              create(:child_care_transaction_category,
                     gross_income_summary: assessment.applicant_gross_income_summary,
                     cash_transactions: build_list(:cash_transaction, 1, amount: 800))
            end

            context "when employed" do
              let(:employed) { true }
              let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: salary / 12.0) }

              it "is eligible" do
                expect(assessment_result).to eq("eligible")
              end
            end

            context "when unemployed with partner" do
              let(:employed) { false }

              before do
                create(:partner_capital_summary, assessment:)
                create(:partner_gross_income_summary, assessment:)
                create(:partner_disposable_income_summary, assessment:)
              end

              context "with partner employment" do
                let(:partner) { build :applicant, employed: true }
                let(:partner_employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: salary / 12.0) }
                let(:salary) { 17_000 }

                it "is eligible" do
                  expect(assessment_result).to eq("eligible")
                end
              end

              context "with partner student loan" do
                let(:partner) { build :applicant, employed: false }

                before do
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
            let(:dependants) { [] }
            let(:proceeding_types) { %w[DA001] }
            let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: 3_000) }

            before do
              create(:housing_cost, amount: 2000,
                                    gross_income_summary: assessment.applicant_gross_income_summary)
            end

            it "is not eligible due to housing cost cap" do
              expect(assessment_result).to eq("contribution_required")
            end

            context "with partner" do
              let(:partner) { build(:applicant) }

              before do
                create(:partner_capital_summary, assessment:)
                create(:partner_gross_income_summary, assessment:)
                create(:partner_disposable_income_summary, assessment:)
              end

              it "is eligible due to cap being removed" do
                expect(assessment_result).to eq("eligible")
              end
            end
          end

          context "with employment" do
            let(:salary) { 15_000 }
            let(:dependants) { [] }

            context "when unemployed" do
              let(:employed) { false }

              it "is below the theshold and thus eligible" do
                expect(assessment_result).to eq("eligible")
              end

              context "with an employed partner" do
                let(:partner) { build(:applicant, employed: true) }
                let(:partner_employments) { build_list(:partner_employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: salary / 12.0) }
                let(:salary) { 5_000 }

                before do
                  create(:partner_capital_summary, assessment:)
                  create(:partner_gross_income_summary, assessment:)
                  create(:partner_disposable_income_summary, assessment:)
                end

                it "is eligible due to partner allowance" do
                  expect(assessment_result).to eq("eligible")
                end
              end
            end

            context "when employed" do
              let(:employed) { true }
              let(:employments) { build_list(:employment, 1, :with_monthly_payments, submission_date: assessment.submission_date, gross_monthly_income: salary / 12.0) }

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
