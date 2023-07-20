require "rails_helper"

module RemarkGenerators
  RSpec.describe MultiBenefitChecker do
    context "state benefit payments" do
      let(:amount) { 123.45 }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:collection) { [payment1, payment2, payment3] }

      subject(:checker) { described_class.call(collection) }

      context "no flags" do
        let(:payment1) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[0] }
        let(:payment2) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[1] }
        let(:payment3) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[2] }

        it "does not update the remarks class" do
          expect(checker).to be_nil
        end
      end

      context "variation in amount" do
        let(:payment1) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[0] }
        let(:payment2) { create :state_benefit_payment, state_benefit:, amount:, payment_date: dates[1] }
        let(:payment3) { create :state_benefit_payment, :with_multi_benefit_flag, state_benefit:, amount:, payment_date: dates[2] }

        it "adds the remark" do
          expect(checker).to eq(RemarksData.new(type: :state_benefit_payment, issue: :multi_benefit, ids: collection.map(&:client_id)))
        end
      end
    end
  end
end
