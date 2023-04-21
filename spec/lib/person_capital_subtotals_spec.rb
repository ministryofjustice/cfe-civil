require "rails_helper"

describe PersonCapitalSubtotals do
  let(:subtotals) do
    described_class.new(
      total_liquid: 45.36,
      total_non_liquid: 14_000,
      total_vehicle: 500,
      total_property: 35_000,
      disputed_property_disregard: 15_913,
      disputed_non_property_disregard: 12_987,
    )
  end

  describe "#total_non_disputed_capital" do
    it "succeeds" do
      expect(subtotals.total_non_disputed_capital).to eq(20_645.36)
    end
  end
end
