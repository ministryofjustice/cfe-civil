require "rails_helper"

module Decorators
  module V6
    RSpec.describe RemarksDecorator do
      let(:assessment) { create :assessment }
      let(:remarks) do
        {
          client: [
            RemarksData.new(:other_income_payment, :unknown_frequency, %w[abc]),
            RemarksData.new(:other_income_payment, :amount_variation, %w[ghu]),
            RemarksData.new(:state_benefit_payment, :residual_balance, %w[cde]),
          ],
          partner: [
            RemarksData.new(:other_income_payment, :unknown_frequency, %w[def]),
            RemarksData.new(:other_income_payment, :amount_variation, %w[jkl]),
            RemarksData.new(:state_benefit_payment, :residual_balance, %w[sss]),
          ],
        }
      end

      let(:explicit_remarks) { [build(:explicit_remark, remark: "test remark")] }

      subject(:remarks_decorator) { described_class.new(explicit_remarks, remarks, assessment_result) }
      describe "#as_json" do
        context "assessment_result is contribution_required" do
          let(:assessment_result) { :contribution_required }

          it "return remarks with explicit remarks" do
            expect(remarks_decorator.as_json).to eq(
              {
                client_other_income_payment: {
                  unknown_frequency: %w[abc],
                  amount_variation: %w[ghu],
                },
                client_state_benefit_payment:
                  {
                    residual_balance: %w[cde],
                  },
                partner_other_income_payment: {
                  unknown_frequency: %w[def],
                  amount_variation: %w[jkl],
                },
                partner_state_benefit_payment:
                  {
                    residual_balance: %w[sss],
                  },
                policy_disregards: ["test remark"],
              },
            )
          end
        end

        context "assessment_result is not contribution_required" do
          let(:assessment_result) { :ineligible }

          it "return remarks without explicit remarks" do
            expect(remarks_decorator.as_json).to eq(
              {
                client_other_income_payment: {
                  unknown_frequency: %w[abc],
                  amount_variation: %w[ghu],
                },
                client_state_benefit_payment:
                  {
                    residual_balance: %w[cde],
                  },
                partner_other_income_payment: {
                  unknown_frequency: %w[def],
                  amount_variation: %w[jkl],
                },
                partner_state_benefit_payment:
                  {
                    residual_balance: %w[sss],
                  },
              },
            )
          end
        end
      end
    end
  end
end
