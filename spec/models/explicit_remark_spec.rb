require "rails_helper"

RSpec.describe ExplicitRemark, type: :model do
  let(:assessment2) { create :assessment }
  let(:assessment1) { create :assessment }

  describe "#by_category" do
    let(:remarks) do
      [
        build(:explicit_remark, remark: "Remark no. 2"),
        build(:explicit_remark, remark: "Remark no. 3"),
        build(:explicit_remark, remark: "Remark no. 1"),
      ]
    end

    context "remarks exist for specified assessment" do
      let(:expected_results) do
        {
          policy_disregards: [
            "Remark no. 1",
            "Remark no. 2",
            "Remark no. 3",
          ],
        }
      end

      it "returns the results in alphabetical order" do
        expect(described_class.by_category(remarks)).to eq(expected_results)
      end
    end
  end
end
