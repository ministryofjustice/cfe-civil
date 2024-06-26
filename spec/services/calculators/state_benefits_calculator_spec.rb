require "rails_helper"

module Calculators
  RSpec.describe StateBenefitsCalculator, :calls_bank_holiday do
    let(:submission_date) { Date.new(2022, 6, 6) }
    let(:assessment) { build :assessment, submission_date: }

    subject(:collator) do
      described_class.benefits(regular_transactions:,
                               submission_date: assessment.submission_date, state_benefits:)
    end

    context "no state benefit records" do
      let(:state_benefits) { [] }
      let(:regular_transactions) { [] }

      it "leaves the monthly state benefit value as zero" do
        expect(collator.state_benefits_bank).to eq 0.0
      end
    end

    context "state benefit records exist" do
      let(:state_benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }

      context "weekly payments" do
        let(:state_benefits) do
          build_list(:state_benefit, 1, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 216.67), exclude_from_gross_income: false)
        end
        let(:regular_transactions) { [] }

        it "returns correct total monthly state benefits" do
          expect(collator.state_benefits_bank).to eq 216.67
        end
      end

      context "post MTR, where housing benefit is included" do
        let(:housing_benefit_type) { create :state_benefit_type, :housing_benefit }
        let(:submission_date) { Date.new(2525, 6, 6) }
        let(:state_benefits) do
          build_list(:state_benefit, 1, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 236.67), exclude_from_gross_income: false)
        end

        let(:regular_transactions) do
          build_list :housing_benefit_regular, 1, amount: 20, frequency: "monthly"
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

      context "mixture of included and excluded benefits" do
        let(:state_benefits) do
          [
            build(:state_benefit, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 216.67), exclude_from_gross_income: false),
            build(:state_benefit, state_benefit_payments: build_list(:state_benefit_payment, 3, amount: 112.67), exclude_from_gross_income: true),
          ]
        end
        let(:regular_transactions) { [] }

        it "returns correct sum amounts of only included benefits" do
          expect(collator.state_benefits_bank).to eq(216.67)
        end
      end
    end
  end
end
