require "rails_helper"

RSpec.describe Calculators::TaxNiRefundCalculator do
  let(:calculator) { described_class.call(employment_payments: employment.employment_payments) }

  let(:submission_date) { Date.new(2022, 6, 6) }
  let(:employment) { build :employment, employment_payments: payments }
  let(:payments) do
    %w[2021-09-30 2021-10-29 2021-11-30].map.with_index do |date_string, i|
      build :employment_payment,
            date: Date.parse(date_string),
            gross_income: 1000,
            benefits_in_kind: 100,
            tax: tax_amounts[i],
            national_insurance: ni_amounts[i]
    end
  end

  let(:remarks) { calculator.map(&:remarks).reduce(&:+) }

  subject(:payment_results) { calculator.map(&:payment) }

  context "when there are no refunds" do
    let(:ni_amounts) { [-10, -20, -30] }
    let(:tax_amounts) { [-50, -60, -70] }

    it "does not change the tax or ni amount value" do
      expect(remarks).to eq([])
      expect(payment_results.map(&:tax)).to match_array(tax_amounts)
      expect(payment_results.map(&:national_insurance)).to match_array(ni_amounts)
    end
  end

  context "when there are tax refunds only" do
    let(:ni_amounts) { [-10, -20, -30] }
    let(:tax_amounts) { [50, -60, -70] }

    it "changes the tax amount value, but not the NI" do
      refund_payment = employment.employment_payments.detect { |pmt| pmt.tax > 0 }
      expect(remarks).to eq([RemarksData.new(type: :employment_tax, issue: :refunds, ids: [refund_payment.client_id])])
      expect(payment_results.map(&:tax)).to match_array([0, -60, -70])
      expect(payment_results.map(&:national_insurance)).to match_array(ni_amounts)
    end
  end

  context "when there are ni refunds only" do
    let(:ni_amounts) { [10, -20, -30] }
    let(:tax_amounts) { [-50, -60, -70] }

    it "changes the ni amount value, but not the tax amount value" do
      refund_payment = employment.employment_payments.detect { |pmt| pmt.national_insurance > 0 }
      expect(remarks).to eq([RemarksData.new(type: :employment_nic, issue: :refunds, ids: [refund_payment.client_id])])
      expect(payment_results.map(&:national_insurance)).to match_array([0, -20, -30])
      expect(payment_results.map(&:tax)).to match_array(tax_amounts)
    end
  end

  context "when there are tax and NI refunds" do
    let(:ni_amounts) { [10, -20, -30] }
    let(:tax_amounts) { [50, -60, -70] }

    it "changes the tax and NI amount values" do
      refund_tax_payment = employment.employment_payments.detect { |pmt| pmt.tax > 0 }
      refund_ni_payment = employment.employment_payments.detect { |pmt| pmt.national_insurance > 0 }
      expect(remarks).to match_array([
        RemarksData.new(type: :employment_tax, issue: :refunds, ids: [refund_tax_payment.client_id]),
        RemarksData.new(type: :employment_nic, issue: :refunds, ids: [refund_ni_payment.client_id]),
      ])
    end
  end
end
