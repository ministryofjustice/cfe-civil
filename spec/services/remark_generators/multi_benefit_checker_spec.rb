require "rails_helper"

module RemarkGenerators
  RSpec.describe MultiBenefitChecker do
    context "state benefit payments" do
      let(:amount) { 123.45 }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:collection) { [current_payment, one_month_payment, two_month_payment] }

      subject(:checker) { described_class.call(collection) }

      context "no flags" do
        let(:current_payment) { build :state_benefit_payment, amount:, payment_date: dates[0] }
        let(:one_month_payment) { build :state_benefit_payment, amount:, payment_date: dates[1] }
        let(:two_month_payment) { build :state_benefit_payment, amount:, payment_date: dates[2] }

        it "does not update the remarks class" do
          expect(checker).to be_nil
        end
      end

      context "variation in amount" do
        let(:current_payment) { build :state_benefit_payment, amount:, payment_date: dates[0] }
        let(:one_month_payment) { build :state_benefit_payment, amount:, payment_date: dates[1] }
        let(:two_month_payment) { build :state_benefit_payment, :with_multi_benefit_flag, amount:, payment_date: dates[2] }

        it "adds the remark" do
          expect(checker).to eq(RemarksData.new(type: :state_benefit_payment, issue: :multi_benefit, ids: collection.map(&:client_id)))
        end
      end
    end
  end
end
