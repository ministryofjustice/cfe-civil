require "rails_helper"

module Assessors
  RSpec.describe NonLiquidCapitalAssessor do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.applicant_capital_summary }

    subject(:non_liquid_total) { described_class.call(non_liquid_capital_items).map(&:result).sum(&:value) }

    context "all positive supplied" do
      let(:non_liquid_capital_items) do
        build_list :non_liquid_capital_item, 3
      end

      it "adds them all together" do
        expect(non_liquid_total).to eq non_liquid_capital_items.sum(&:value)
      end
    end

    context "no values supplied" do
      let(:non_liquid_capital_items) { [] }

      it "returns zero" do
        expect(non_liquid_total).to eq 0.0
      end
    end
  end
end
