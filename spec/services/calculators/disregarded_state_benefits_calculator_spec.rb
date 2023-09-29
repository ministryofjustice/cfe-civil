require "rails_helper"

module Calculators
  RSpec.describe DisregardedStateBenefitsCalculator do
    let(:state_benefits_input) do
      state_benefits.map do |sb|
        OpenStruct.new(monthly_value: 88.3, exclude_from_gross_income?: sb.exclude_from_gross_income)
      end
    end

    subject(:calculator) do
      described_class.call(state_benefits_input)
    end

    context "no state benefit payments" do
      let(:state_benefits) { [] }

      it "returns zero" do
        expect(calculator).to eq 0
      end
    end

    context "only included state benefit payments" do
      let(:state_benefits) do
        [OpenStruct.new(exclude_from_gross_income: false)]
      end

      it "returns zero" do
        expect(calculator).to eq 0
      end
    end

    context "has excluded state benefit payments" do
      let(:state_benefits) do
        [OpenStruct.new(exclude_from_gross_income: true),
         OpenStruct.new(exclude_from_gross_income: false),
         OpenStruct.new(exclude_from_gross_income: true)]
      end

      it "returns value x 2" do
        expect(calculator).to eq 176.6
      end
    end
  end
end
