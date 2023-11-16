require "rails_helper"

RSpec.describe ExplicitRemark, type: :model do
  it { is_expected.to belong_to(:assessment) }

  let(:assessment1) { create :assessment }
  let(:assessment2) { create :assessment }

  describe "#by_category" do
    before do
      create :explicit_remark, assessment: assessment2, remark: "Remark no. 2"
      create :explicit_remark, assessment: assessment2, remark: "Remark no. 3"
      create :explicit_remark, assessment: assessment2, remark: "Remark no. 1"
    end

    context "no remarks for specified assessment" do
      it "returns an empty hash" do
        expect(assessment1.explicit_remarks.by_category).to eq({})
      end
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
        expect(assessment2.explicit_remarks.by_category).to eq(expected_results)
      end
    end
  end
end
