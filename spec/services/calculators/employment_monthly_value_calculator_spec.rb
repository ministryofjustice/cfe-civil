require "rails_helper"

RSpec.describe Calculators::EmploymentMonthlyValueCalculator do
  describe ".call" do
    let(:submission_date) { Date.new(2022, 6, 6) }
    let(:employment) { build(:employment) }

    it "calls the tax and national insurance refund calculator" do
      allow(Calculators::TaxNiRefundCalculator).to receive(:call).and_return([])

      described_class.call employment, submission_date, []

      expect(Calculators::TaxNiRefundCalculator)
        .to have_received(:call)
        .with(employment_payments: employment.employment_payments)
        .exactly(1).time
    end

    context "when there are employment payments" do
      let(:monthly_equiv_payment_data) { Utilities::EmploymentIncomeMonthlyEquivalentCalculator::MonthlyEquivPaymentData }
      let(:payments) do
        [
          monthly_equiv_payment_data.new(date: Date.yesterday, benefits_in_kind_monthly_equiv: 10, gross_income_monthly_equiv: 90, national_insurance_monthly_equiv: -10, tax_monthly_equiv: -20),
          monthly_equiv_payment_data.new(date: Date.current, benefits_in_kind_monthly_equiv: 10, gross_income_monthly_equiv: 490, national_insurance_monthly_equiv: -20, tax_monthly_equiv: -50),
        ]
      end

      context "when variation in employment income is below the threshold" do
        before do
          variation_checker = instance_double(
            Utilities::EmploymentIncomeVariationChecker,
            below_threshold?: true,
          )
          allow(Utilities::EmploymentIncomeVariationChecker)
            .to receive(:new)
            .and_return(variation_checker)
        end

        it "updates the monthly gross income, national insurance, and tax to " \
           "the most recent payment" do
          expect(described_class.call(employment, submission_date, payments).values)
            .to eq(
              monthly_gross_income: 490,
              monthly_benefits_in_kind: 10,
              monthly_national_insurance: -20,
              monthly_tax: -50,
            )
        end

        it "does not add a remark to the assessment" do
          remarks = described_class.call(employment, submission_date, payments).remarks
          expect(remarks).to eq([])
        end
      end

      context "when variation in employment income is above the threshold" do
        before do
          variation_checker = instance_double(
            Utilities::EmploymentIncomeVariationChecker,
            below_threshold?: false,
          )
          allow(Utilities::EmploymentIncomeVariationChecker)
            .to receive(:new)
            .and_return(variation_checker)
        end

        it "updates the monthly gross income, national insurance, and tax to " \
           "the blunt average" do
          expect(described_class.call(employment, submission_date, payments).values)
            .to eq(
              monthly_gross_income: 290,
              monthly_national_insurance: -15,
              monthly_tax: -35,
              monthly_benefits_in_kind: 10,
            )
        end

        it "adds a remark to the assessment" do
          remarks = described_class.call(employment, submission_date, payments).remarks

          employment_payments = employment.employment_payments
          expect(remarks).to eq([RemarksData.new(type: :employment_gross_income, issue: :amount_variation, ids: employment_payments.map(&:client_id))])
        end
      end
    end

    context "when there are no employment payments" do
      it "zeros the monthly gross income, national insurance, and tax" do
        expect(described_class.call(employment, submission_date, []).values)
          .to eq(
            monthly_gross_income: 0,
            monthly_national_insurance: 0,
            monthly_tax: 0,
            monthly_benefits_in_kind: 0,
          )
      end
    end
  end
end
