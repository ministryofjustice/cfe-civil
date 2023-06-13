require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) do
      create :assessment, :with_capital_summary, :with_disposable_income_summary,
             :with_gross_income_summary,
             submission_date: Date.new(2022, 6, 7),
             applicant:, proceedings: proceeding_types.map { |p| [p, "A"] }, level_of_help:
    end
    let(:person_blank) { PersonData.new(self_employments: [], vehicles: [], dependants: []) }
    let(:person_applicant) { PersonData.new(self_employments: [], vehicles: [], dependants:) }

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :gross_income_eligibility, gross_income_summary: assessment.applicant_gross_income_summary, upper_threshold: gross_income_upper_threshold, proceeding_type_code: ptc
        create :disposable_income_eligibility, disposable_income_summary: assessment.applicant_disposable_income_summary,
                                               upper_threshold: disposable_income_upper_threshold,
                                               lower_threshold: 500,
                                               proceeding_type_code: ptc
      end
      Creators::CapitalEligibilityCreator.call(assessment)
    end

    context "vehicle collection output", :calls_bank_holiday do
      let(:disposable_income_upper_threshold) { 5000 }
      let(:applicant) { build :applicant }
      let(:proceeding_types) { %w[SE003] }
      let(:level_of_help) { "certificated" }
      let(:self_employments) do
        [OpenStruct.new(income: SelfEmploymentIncome.new(tax: 200, benefits_in_kind: 100,
                                                         national_insurance: 150, gross: 2900, frequency: "monthly"))]
      end
      let(:person_applicant) { PersonData.new(self_employments: [], vehicles: build_list(:vehicle, 1), dependants: []) }
      let(:partner_applicant) { person_applicant }

      subject(:calculation_output) do
        assessment.reload
        described_class.call(assessment:, applicant: person_applicant, partner: partner_applicant).tap do
          Assessors::MainAssessor.call(assessment)
        end
      end

      before do
        create(:partner, assessment:)
        create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: 4000)
        assessment.proceeding_type_codes.each do |ptc|
          create(:assessment_eligibility, assessment:, proceeding_type_code: ptc)
        end
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
        described_class.call(assessment:, applicant: person_applicant, partner: person_blank)
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
        let(:dependants) { [] }

        describe "self employed" do
          let(:applicant) { build :applicant }
          let(:calculation_output) do
            assessment.reload
            described_class.call(assessment:,
                                 applicant: PersonData.new(self_employments:, vehicles: [], dependants: []),
                                 partner: person_blank).tap do
              Assessors::MainAssessor.call(assessment)
            end
          end
          let(:employment_income_subtotals) { calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals }

          describe "frequencies" do
            let(:self_employments) do
              [OpenStruct.new(income: SelfEmploymentIncome.new(tax: -200, benefits_in_kind: 100,
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
                OpenStruct.new(income: SelfEmploymentIncome.new(tax: -220, benefits_in_kind: 20, national_insurance: -20, gross: 520, frequency: "monthly")),
                OpenStruct.new(income: SelfEmploymentIncome.new(tax: -420, benefits_in_kind: 20, national_insurance: -40, gross: 720, frequency: "monthly", is_employment: true)),
              ]
            end

            it "returns employment figures" do
              expect(employment_income_subtotals)
                .to have_attributes(fixed_employment_allowance: -45.0,
                                    gross_employment_income: 1240.0,
                                    benefits_in_kind: 40.0,
                                    national_insurance: -60.0,
                                    tax: -640.0,
                                    employment_income_deductions: -700.0)
            end
          end
        end

        describe "capital thresholds for controlled" do
          let(:self_employments) { [] }
          let(:applicant) { build :applicant, :under_pensionable_age }

          before do
            create(:property, :additional_property, capital_summary: assessment.applicant_capital_summary,
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
        let(:self_employments) { [] }

        context "with capital" do
          let(:dependants) { [] }

          before do
            create(:property, :additional_property, capital_summary: assessment.applicant_capital_summary,
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
            let(:dependants) { build_list(:dependant, 1, :under15, submission_date: assessment.submission_date) }

            before do
              create(:child_care_transaction_category,
                     gross_income_summary: assessment.applicant_gross_income_summary,
                     cash_transactions: build_list(:cash_transaction, 1, amount: 800))
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
            let(:dependants) { [] }

            before do
              create(:employment, :with_monthly_payments, assessment:,
                                                          gross_monthly_income: 3_000)
              create(:housing_cost, amount: 1000,
                                    gross_income_summary: assessment.applicant_gross_income_summary)
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
            let(:salary) { 15_000 }
            let(:dependants) { [] }

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
