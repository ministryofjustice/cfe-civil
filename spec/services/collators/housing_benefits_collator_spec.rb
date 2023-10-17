require "rails_helper"

module Collators
  RSpec.describe HousingBenefitsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
    let(:gross_income_summary) { assessment.applicant_gross_income_summary }

    subject(:housing_benefit) do
      described_class.call(state_benefits: build_list(:state_benefit, 1, :housing_benefit, state_benefit_payments: housing_benefit_payments),
                           gross_income_summary: assessment.applicant_gross_income_summary)
    end

    describe "#housing_benefit" do
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

      context "with state_benefits of housing_benefit type" do
        let(:housing_benefit_payments) do
          [
            build(:state_benefit_payment, amount: 222.22, payment_date: dates[0]),
            build(:state_benefit_payment, amount: 222.22, payment_date: dates[2]),
          ]
        end

        it "returns monthly equivalent" do
          expect(housing_benefit).to eq 148.15 # (222.22 + 222.22) / 3
        end
      end

      context "with housing benefit as a state_benefit" do
        let(:housing_benefit_payments) do
          [build(:state_benefit_payment, amount: 101.02, payment_date: Date.current),
           build(:state_benefit_payment, amount: 101.02, payment_date: 1.month.ago),
           build(:state_benefit_payment, amount: 101.02, payment_date: 2.months.ago)]
        end

        it "has expected housing cost attributes" do
          expect(housing_benefit).to eq(101.02)
        end
      end

      context "with regular_transactions of housing_benefit type" do
        let(:housing_benefit_payments) { [] }

        before do
          create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "three_monthly", amount: 1000.00)
        end

        it "returns monthly equivalent" do
          expect(housing_benefit).to eq 333.33 # 1000.00 / 3
        end
      end
    end
  end
end
