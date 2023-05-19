require "rails_helper"

module Calculators
  RSpec.describe DisregardedStateBenefitsCalculator do
    let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }
    let(:included_state_benefit_type) { create :state_benefit_type, :benefit_included }
    let(:excluded_state_benefit_type) { create :state_benefit_type, :benefit_excluded }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:state_benefits_input) do
      gross_income_summary.state_benefits.map do |sb|
        OpenStruct.new(monthly_value: 88.3, exclude_from_gross_income?: sb.exclude_from_gross_income)
      end
    end

    subject(:calculator) do
      described_class.call(state_benefits_input)
    end

    context "no state benefit payments" do
      it "returns zero" do
        expect(calculator).to eq 0
      end
    end

    context "only included state benefit payments" do
      before do
        create :state_benefit, :with_monthly_payments, state_benefit_type: included_state_benefit_type, gross_income_summary:
      end

      it "returns zero" do
        expect(calculator).to eq 0
      end
    end

    context "has excluded state benefit payments" do
      before do
        create(:state_benefit, :with_monthly_payments, state_benefit_type: excluded_state_benefit_type, gross_income_summary:)
        create(:state_benefit, :with_monthly_payments, state_benefit_type: included_state_benefit_type, gross_income_summary:)
        create :state_benefit, :with_monthly_payments, state_benefit_type: excluded_state_benefit_type, gross_income_summary:
      end

      it "returns value x 2" do
        expect(calculator).to eq 176.6
      end
    end
  end
end
