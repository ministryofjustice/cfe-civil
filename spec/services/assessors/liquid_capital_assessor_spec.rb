require "rails_helper"

module Assessors
  RSpec.describe LiquidCapitalAssessor do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.capital_summary }

    context "all positive supplied" do
      it "adds them all together" do
        create_list(:liquid_capital_item, 3, capital_summary:)
        expect(described_class.call(capital_summary.liquid_capital_items)).to eq capital_summary.liquid_capital_items.sum(&:value)
      end
    end

    context "mixture of positive and negative supplied" do
      it "ignores negative values" do
        create :liquid_capital_item, capital_summary:, value: 256.77
        create :liquid_capital_item, capital_summary:, value: -150.33
        create :liquid_capital_item, capital_summary:, value: 67.50
        expect(described_class.call(capital_summary.liquid_capital_items)).to eq 324.27
      end
    end

    context "all negative supplied" do
      it "ignores negative values" do
        create_list(:liquid_capital_item, 3, :negative, capital_summary:)
        expect(described_class.call(capital_summary.liquid_capital_items)).to eq 0.0
      end
    end

    context "no values supplied" do
      it "returns 0" do
        expect(described_class.call(capital_summary.liquid_capital_items)).to eq 0.0
      end
    end
  end
end
