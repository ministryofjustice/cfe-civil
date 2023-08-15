require "rails_helper"

module Collators
  RSpec.describe DisposableIncomeCollator do
    let(:assessment) { disposable_income_summary.assessment }
    let(:child_care_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:maintenance_out_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:gross_housing) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:legal_aid_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:housing_benefit) { Faker::Number.between(from: 1.25, to: gross_housing / 2).round(2) }
    let(:net_housing) { gross_housing - housing_benefit }
    let(:tax) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:national_insurance) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:fixed_employment_allowance) { 45.0 }
    let(:dependant_allowance_under_16) { 282.98 }
    let(:dependant_allowance_over_16) { 300.00 }
    let(:partner_allowance) { 481.29 }
    let(:total_gross_income) { 0 }
    let(:gross_income_subtotals) do
      PersonGrossIncomeSubtotals.new(
        gross_income_summary: assessment.applicant_gross_income_summary,
        regular_income_categories: [],
        employment_income_subtotals: instance_double(EmploymentIncomeSubtotals,
                                                     benefits_in_kind: 0,
                                                     employment_income_deductions: tax + national_insurance,
                                                     tax:,
                                                     national_insurance:,
                                                     fixed_employment_allowance:,
                                                     # This 50 is to offset 600/year in student loan in the factory, so that we control total_gross_income
                                                     gross_employment_income: total_gross_income - 50),
      )
    end

    let(:disposable_income_summary) do
      create(:disposable_income_summary,
             total_outgoings_and_allowances: 0.0,
             total_disposable_income: 0.0).tap do |summary|
        create :disposable_income_eligibility, disposable_income_summary: summary, proceeding_type_code: "DA001"
      end
    end

    let(:total_outgoings) do
      maintenance_out_cash +
        legal_aid_cash +
        child_care_bank +
        maintenance_out_bank +
        legal_aid_bank +
        net_housing +
        dependant_allowance_under_16 + dependant_allowance_over_16 -
        (tax + national_insurance) -
        fixed_employment_allowance +
        partner_allowance
    end

    # this comes from create :gross_income_summary, :with_all_records and is a random amount each time
    let(:legal_aid_cash) { Calculators::MonthlyCashTransactionAmountCalculator.call(assessment.applicant_gross_income_summary.cash_transactions(:debit, :legal_aid)) }
    let(:maintenance_out_cash) { Calculators::MonthlyCashTransactionAmountCalculator.call(assessment.applicant_gross_income_summary.cash_transactions(:debit, :maintenance_out)) }

    before { create :gross_income_summary, :with_all_records, assessment: }

    describe ".call" do
      subject(:collator) do
        described_class.call(gross_income_summary: assessment.applicant_gross_income_summary,
                             disposable_income_summary:,
                             partner_allowance:,
                             gross_income_subtotals:,
                             outgoings: OutgoingsCollator::Result.new(
                               child_care: ChildcareCollator::Result.new(bank: child_care_bank, cash: 0),
                               dependant_allowance: DependantsAllowanceCollator::Result.new(under_16: dependant_allowance_under_16,
                                                                                            over_16: dependant_allowance_over_16),
                               rent_or_mortgage_bank: 0,
                               legal_aid_bank:,
                               maintenance_out_bank:,
                               housing_costs: Collators::HousingCostsCollator::Result.new(
                                 housing_benefit:,
                                 gross_housing_costs: gross_housing,
                                 gross_housing_costs_bank: 0,
                                 net_housing_costs: net_housing,
                               ),
                             ))
      end

      context "total_monthly_outgoings" do
        before do
          collator
        end

        it "sums childcare, legal_aid, maintenance, net housing costs and allowances" do
          expect(disposable_income_summary.total_outgoings_and_allowances.to_f).to eq total_outgoings.to_f
        end
      end

      context "total disposable income" do
        let(:total_gross_income) { total_outgoings + 1_500 }

        before do
          collator
        end

        it "is populated with result of gross income minus total outgoings and allowances" do
          result = total_gross_income - disposable_income_summary.total_outgoings_and_allowances
          expect(disposable_income_summary.total_disposable_income).to eq result
        end
      end

      context "when total disposable income is negative" do
        let(:total_gross_income) { total_outgoings - 1_500 }

        before do
          collator
        end

        it "returns the correct negative amount" do
          result = total_gross_income - disposable_income_summary.total_outgoings_and_allowances
          expect(disposable_income_summary.total_disposable_income).to eq result
          expect(disposable_income_summary.total_disposable_income).to be_negative
        end
      end

      context "lower threshold" do
        it "populates the lower threshold" do
          collator
          expect(disposable_income_summary.eligibilities.first.lower_threshold).to eq 315.0
        end
      end

      context "upper threshold" do
        context "domestic abuse" do
          it "populates it with infinity" do
            collator
            expect(disposable_income_summary.eligibilities.first.upper_threshold).to eq 999_999_999_999.0
          end
        end
      end
    end
  end
end
