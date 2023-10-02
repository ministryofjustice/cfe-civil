require "rails_helper"

module Calculators
  RSpec.describe StateBenefitsCalculator, :calls_bank_holiday do
    let(:submission_date) { Date.new(2022, 6, 6) }
    let(:assessment) { create :assessment, :with_gross_income_summary, submission_date: }
    let(:gross_income_summary) { assessment.applicant_gross_income_summary }

    subject(:collator) { described_class.benefits(gross_income_summary:, submission_date: assessment.submission_date) }

    context "no state benefit records" do
      it "leaves the monthly state benefit value as zero" do
        expect(collator.state_benefits_bank).to eq 0.0
      end
    end

    context "state benefit records exist" do
      let(:state_benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }

      before do
        create :state_benefit,
               :with_weekly_payments,
               gross_income_summary:,
               state_benefit_type: state_benefit_type_included
      end

      context "weekly payments" do
        it "returns correct total monthly state benefits" do
          expect(collator.state_benefits_bank).to eq 216.67
        end
      end

      context "post MTR, where housing benefit is included" do
        let(:housing_benefit_type) { create :state_benefit_type, :housing_benefit }
        let(:submission_date) { Date.new(2525, 6, 6) }

        before do
          create :state_benefit, :with_monthly_payments,
                 payment_amount: 20,
                 gross_income_summary:, state_benefit_type: housing_benefit_type
          create :housing_benefit_regular, amount: 20, gross_income_summary:, frequency: "monthly"
        end

        #  avoid 'date cannot be in the future' errors
        around do |example|
          travel_to submission_date
          example.run
          travel_back
        end

        it "returns housing benefit as well as state benefits" do
          expect(collator).to have_attributes(state_benefits_bank: 236.67, state_benefits_regular: 20.00)
        end
      end

      context "monthly and weekly payments" do
        let(:another_state_benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }

        before do
          create :state_benefit,
                 :with_monthly_payments,
                 gross_income_summary:,
                 state_benefit_type: another_state_benefit_type_included
        end

        it "returns correct sum of both monthly and weekly benefits" do
          expect(collator.state_benefits_bank).to eq 304.97
        end
      end

      context "mixture of included and excluded benefits" do
        let(:state_benefit_type_excluded) { create :state_benefit_type, exclude_from_gross_income: true }

        before do
          create :state_benefit,
                 :with_monthly_payments,
                 gross_income_summary:,
                 state_benefit_type: state_benefit_type_excluded
        end

        it "returns correct sum amounts of only included benefits" do
          expect(collator.state_benefits_bank).to eq(216.67)
        end
      end
    end
  end
end
