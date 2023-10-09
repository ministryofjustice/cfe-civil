require "rails_helper"

module RemarkGenerators
  RSpec.describe AmountVariationChecker do
    context "state benefit payments" do
      let(:amount) { 123.45 }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:collection) { [payment1, payment2, payment3] }

      context "no variation in amount" do
        let(:payment1) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[0] }
        let(:payment2) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[1] }
        let(:payment3) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[2] }

        it "does not update the remarks class" do
          expect(described_class.call(collection:, child_care_bank: 0)).to be_nil
        end
      end

      context "variation in amount" do
        let(:payment1) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[0] }
        let(:payment2) { create :state_benefit_payment, state_benefit:, amount: amount + 0.01, payment_date: dates[1] }
        let(:payment3) { create :state_benefit_payment, state_benefit:, amount: amount - 0.02, payment_date: dates[2] }

        it "adds the remark" do
          expect(described_class.call(collection:, child_care_bank: 0))
            .to eq(RemarksData.new(type: :state_benefit_payment,
                                   issue: :amount_variation, ids: collection.map(&:client_id)))
        end
      end
    end

    context "outgoings" do
      let(:disposable_income_summary) { create :disposable_income_summary }
      let(:assessment) { disposable_income_summary.assessment }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:amount) { 277.67 }

      context "no variation in amount" do
        let(:collection) do
          [
            build(:housing_cost_outgoing, payment_date: dates[0], amount:),
            build(:housing_cost_outgoing, payment_date: dates[1], amount:),
            build(:housing_cost_outgoing,  payment_date: dates[2], amount:),
          ]
        end

        it "does not update the remarks class" do
          expect(described_class.call(collection:, child_care_bank: 0)).to be_nil
        end
      end

      context "varying amounts" do
        let(:collection) do
          [
            build(:housing_cost_outgoing,  payment_date: dates[0], amount:),
            build(:housing_cost_outgoing,  payment_date: dates[1], amount: amount + 0.01),
            build(:housing_cost_outgoing,  payment_date: dates[2], amount:),
          ]
        end

        it "adds the remark" do
          expect(described_class.call(collection:, child_care_bank: 0))
            .to eq(RemarksData.new(type: :outgoings_housing_cost,
                                   issue: :amount_variation, ids: collection.map(&:client_id)))
        end
      end

      context "when childcare costs with an amount variation are declared" do
        let(:collection) do
          [
            build(:childcare_outgoing, payment_date: dates[0], amount:),
            build(:childcare_outgoing,  payment_date: dates[1], amount: amount + 0.01),
            build(:childcare_outgoing,  payment_date: dates[2], amount:),
          ]
        end

        context "if the childcare costs are allowed as an outgoing" do
          it "adds the remark" do
            expect(described_class.call(collection:, child_care_bank: 1))
              .to eq(RemarksData.new(type: :outgoings_childcare,
                                     issue: :amount_variation, ids: collection.map(&:client_id)))
          end
        end

        context "if the childcare costs are not allowed as an outgoing" do
          it "does not update the remarks class" do
            expect(described_class.call(collection:, child_care_bank: 0)).to be_nil
          end
        end
      end
    end
  end
end
