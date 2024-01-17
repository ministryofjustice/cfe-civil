require "rails_helper"

module Collators
  RSpec.describe GrossIncomeCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, proceedings: proceeding_type_codes }
    let(:employments) { [] }
    let(:other_income_payments) { [] }
    let(:person) do
      build(:person_data,
            other_income_payments:,
            details: build(:applicant),
            irregular_income_payments:, employments:)
    end

    describe ".call" do
      subject(:collator) do
        described_class.call submission_date: assessment.submission_date,
                             person:
      end

      context "only domestic abuse proceeding type codes" do
        let(:proceeding_type_codes) { [%w[DA001 A]] }

        context "monthly_other_income" do
          let(:irregular_income_payments) { [] }

          context "there are no other income records" do
            it "set monthly other income to zero" do
              expect(collator.person_gross_income_subtotals)
                .to have_attributes(monthly_unspecified_source: 0.0, monthly_student_loan: 0.0)
            end
          end

          context "monthly_other_income_sources_exist" do
            let(:other_income_payments) do
              [
                build(:other_income_payment, category: :friends_or_family, payment_date: Date.current, amount: 105.13),
                build(:other_income_payment, category: :friends_or_family, payment_date: 1.month.ago.to_date, amount: 105.23),
                build(:other_income_payment, category: :friends_or_family, payment_date: 1.month.ago.to_date, amount: 105.03),
                build(:other_income_payment, category: :property_or_lodger, payment_date: Date.current, amount: 66.45),
                build(:other_income_payment, category: :property_or_lodger, payment_date: 1.month.ago.to_date, amount: 66.45),
                build(:other_income_payment, category: :property_or_lodger, payment_date: 1.month.ago.to_date, amount: 66.45),
              ]
            end

            it "updates the gross income record with categorised monthly incomes" do
              response = collator.person_gross_income_subtotals
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :friends_or_family)).to eq 105.13
              expect(response.monthly_regular_incomes(:all_sources, :property_or_lodger)).to eq 66.45
              expect(response.total_gross_income).to eq 171.58
            end
          end
        end

        context "monthly_student_loan" do
          context "there are no irregular income payments" do
            let(:irregular_income_payments) { [] }

            it "set monthly student loan to zero" do
              response = collator.person_gross_income_subtotals
              expect(response.monthly_student_loan).to eq 0.0
            end
          end

          context "monthly_student_loan exists" do
            let(:irregular_income_payments) { build_list :irregular_income_payment, 1, amount: 12_000 }

            it "updates the gross income record with categorised monthly incomes" do
              response = collator.person_gross_income_subtotals
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_student_loan).to eq 12_000 / 12
              expect(response.total_gross_income).to eq 12_000 / 12
            end
          end
        end

        context "monthly_unspecified_source" do
          context "there are no irregular income payments" do
            let(:irregular_income_payments) { [] }

            it "set monthly income from unspecified sources to zero" do
              response = collator.person_gross_income_subtotals
              expect(response.monthly_unspecified_source).to eq 0.0
            end
          end

          context "monthly_unspecified_source exists" do
            let(:irregular_income_payments) do
              build_list :irregular_income_payment, 1,
                         amount: 12_000,
                         income_type: :unspecified_source,
                         frequency: "quarterly"
            end

            it "updates the gross income record with categorised monthly incomes" do
              response = collator.person_gross_income_subtotals
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_unspecified_source).to eq 12_000 / 3
              expect(response.total_gross_income).to eq 12_000 / 3
            end
          end
        end

        context "bank and cash transactions" do
          let(:assessment) { create :assessment }
          let(:irregular_income_payments) { [] }

          it "updates with totals for all categories based on bank and cash transactions" do
            response = collator.person_gross_income_subtotals
            expect(response.monthly_regular_incomes(:all_sources, :benefits)).to eq(
              response.monthly_regular_incomes(:cash, :benefits) + response.monthly_regular_incomes(:bank, :benefits),
            )
            expect(response.monthly_regular_incomes(:all_sources, :friends_or_family)).to eq(
              response.monthly_regular_incomes(:cash, :friends_or_family) + response.monthly_regular_incomes(:bank, :friends_or_family),
            )
            expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to eq(
              response.monthly_regular_incomes(:cash, :maintenance_in) + response.monthly_regular_incomes(:bank, :maintenance_in),
            )
            expect(response.monthly_regular_incomes(:all_sources, :property_or_lodger)).to eq(
              response.monthly_regular_incomes(:cash, :property_or_lodger) + response.monthly_regular_incomes(:bank, :property_or_lodger),
            )
            expect(response.monthly_regular_incomes(:all_sources, :pension)).to eq(
              response.monthly_regular_incomes(:cash, :pension) + response.monthly_regular_incomes(:bank, :pension),
            )
          end

          it "has a total gross income based on all sources and monthly student loan" do
            response = collator.person_gross_income_subtotals
            all_sources_total = response.monthly_regular_incomes(:all_sources, :benefits) +
              response.monthly_regular_incomes(:all_sources, :friends_or_family) +
              response.monthly_regular_incomes(:all_sources, :maintenance_in) +
              response.monthly_regular_incomes(:all_sources, :property_or_lodger) +
              response.monthly_regular_incomes(:all_sources, :pension) +
              response.monthly_student_loan +
              response.monthly_unspecified_source

            expect(response.total_gross_income).to eq all_sources_total
          end
        end

        context "gross_employment_income" do
          let(:irregular_income_payments) { [] }
          let(:assessment) { create :assessment }
          let(:disposable_income_summary) { assessment.disposable_income_summary }
          let(:employments) do
            build_list(:employment, 1,
                       employment_payments: build_list(:employment_payment, 1, gross_income: 1500.0, tax: -495,
                                                                               national_insurance: -150, prisoner_levy: -20,
                                                                               student_debt_repayment: -50))
          end

          it "has a total gross employed income" do
            expect(collator.person_gross_income_subtotals.employment_income_subtotals.gross_employment_income).to eq 1500
          end

          it "returns employment_income_subtotals" do
            expect(collator.person_gross_income_subtotals.employment_income_subtotals).to have_attributes(tax: -495, national_insurance: -150, prisoner_levy: -20, student_debt_repayment: -50, fixed_employment_allowance: -45)
          end
        end
      end
    end
  end
end
