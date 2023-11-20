require "rails_helper"

module Decorators
  module V6
    RSpec.describe RemarksDecorator do
      let(:assessment) { create :assessment }
      let(:remarks) do
        [
          RemarksData.new(:other_income_payment, :unknown_frequency, %w[abc def]),
          RemarksData.new(:other_income_payment, :amount_variation, %w[ghu jkl]),
          RemarksData.new(:state_benefit_payment, :residual_balance, %w[cde sss]),
        ]
      end

      before { create :explicit_remark, remark: "test remark", assessment: }

      subject(:remarks_decorator) { described_class.new(assessment.explicit_remarks, remarks, assessment_result) }
      describe "#as_json" do
        context "assessment_result is contribution_required" do
          let(:assessment_result) { :contribution_required }

          it "return remarks with explicit remarks" do
            expect(remarks_decorator.as_json).to eq({ other_income_payment: { unknown_frequency: %w[abc def], amount_variation: %w[ghu jkl] }, state_benefit_payment: { residual_balance: %w[cde sss] }, policy_disregards: ["test remark"] })
          end
        end

        context "assessment_result is not contribution_required" do
          let(:assessment_result) { :ineligible }

          it "return remarks without explicit remarks" do
            expect(remarks_decorator.as_json).to eq({ other_income_payment: { unknown_frequency: %w[abc def], amount_variation: %w[ghu jkl] }, state_benefit_payment: { residual_balance: %w[cde sss] } })
          end
        end
      end
    end
  end
end
