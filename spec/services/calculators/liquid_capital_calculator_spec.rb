require "rails_helper"

module Calculators
  RSpec.describe LiquidCapitalCalculator do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.applicant_capital_summary }

    subject(:liquid_capital_items) do
      described_class.call(liquid_capital_input).map(&:result).sum(0.0, &:value)
    end

    context "all positive supplied" do
      let(:liquid_capital_input) { build_list(:liquid_capital_item, 3) }

      it "adds them all together" do
        expect(liquid_capital_items).to eq liquid_capital_input.sum(&:value)
      end
    end

    context "mixture of positive and negative supplied" do
      let(:liquid_capital_input) do
        [
          build(:liquid_capital_item, value: 256.77),
          build(:liquid_capital_item, value: -150.33),
          build(:liquid_capital_item, value: 67.50),
        ]
      end

      it "ignores negative values" do
        expect(liquid_capital_items).to eq 324.27
      end
    end

    context "all negative supplied" do
      let(:liquid_capital_input) do
        build_list(:liquid_capital_item, 3, :negative)
      end

      it "ignores negative values" do
        expect(liquid_capital_items).to eq 0.0
      end
    end

    context "no values supplied" do
      let(:liquid_capital_input) { [] }

      it "returns 0" do
        expect(liquid_capital_items).to eq 0.0
      end
    end
  end
end
