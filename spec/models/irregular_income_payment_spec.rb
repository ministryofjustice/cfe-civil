require "rails_helper"

RSpec.describe IrregularIncomePayment, type: :model do
  let!(:gross_income_summary) { create :gross_income_summary }
  let!(:payment) { create :irregular_income_payment, gross_income_summary: }

  context "validations" do
    context "invalid income type" do
      let(:payment) { build :irregular_income_payment, income_type: "xxx" }

      it "is not valid" do
        expect(payment).not_to be_valid
        expect(payment.errors[:income_type]).to eq(["is not included in the list"])
      end
    end

    context "frequency" do
      let(:payment) { build :irregular_income_payment, frequency: "xxx" }

      it "is not valid" do
        expect(payment).not_to be_valid
        expect(payment.errors[:frequency]).to eq(["is not included in the list"])
      end
    end

    context "amount is less than zero" do
      let!(:payment) do
        build :irregular_income_payment, amount: -1
      end

      it "raises error" do
        expect(payment).not_to be_valid
        expect(payment.errors.full_messages).to eq(["Amount must be greater than or equal to 0"])
      end
    end
  end
end
