require "rails_helper"

module Assessors
  RSpec.describe LiquidCapitalAssessor do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.applicant_capital_summary }

    subject(:liquid_capital_items) do
      described_class.call(capital_summary.liquid_capital_items).map(&:result).sum(0.0, &:value)
    end

    context "all positive supplied" do
      it "adds them all together" do
        create_list(:liquid_capital_item, 3, capital_summary:)
        expect(liquid_capital_items).to eq capital_summary.liquid_capital_items.sum(&:value)
      end
    end

    context "mixture of positive and negative supplied" do
      before do
        create :liquid_capital_item, capital_summary:, value: 256.77
        create :liquid_capital_item, capital_summary:, value: -150.33
        create :liquid_capital_item, capital_summary:, value: 67.50
      end

      it "ignores negative values" do
        expect(liquid_capital_items).to eq 324.27
      end
    end

    context "all negative supplied" do
      before do
        create_list(:liquid_capital_item, 3, :negative, capital_summary:)
      end

      it "ignores negative values" do
        expect(liquid_capital_items).to eq 0.0
      end
    end

    context "no values supplied" do
      it "returns 0" do
        expect(liquid_capital_items).to eq 0.0
      end
    end
  end
end
