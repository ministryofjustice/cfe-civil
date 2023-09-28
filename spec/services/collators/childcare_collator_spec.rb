require "rails_helper"

module Collators
  RSpec.describe ChildcareCollator, :calls_bank_holiday do
    describe ".call" do
      let(:childcare_outgoings) do
        [
          build(:childcare_outgoing, payment_date: Date.current, amount: 155.63),
          build(:childcare_outgoing, payment_date: 1.month.ago, amount: 155.63),
          build(:childcare_outgoing, payment_date: 2.months.ago, amount: 155.63),
        ]
      end

      subject(:collator) do
        described_class.call(cash_transactions: [], childcare_outgoings:)
      end

      it "adds the the childcare values" do
        expect(collator).to have_attributes(bank: 155.63, cash: 0)
      end
    end
  end
end
