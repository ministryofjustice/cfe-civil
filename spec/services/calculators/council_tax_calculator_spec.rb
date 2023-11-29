require "rails_helper"

RSpec.describe Calculators::CouncilTaxCalculator, :calls_bank_holiday do
  around do |example|
    travel_to submission_date
    example.run
    travel_back
  end

  let(:assessment) do
    create(:assessment, :with_disposable_income_summary, :with_gross_income_summary, submission_date:)
  end

  subject(:council_tax) do
    described_class.call(
      outgoings:,
      cash_transactions:,
      regular_transactions:,
      submission_date:,
    )
  end

  describe "#council_tax" do
    let(:outgoings) { build_list(:council_tax_outgoing, 3, amount: 100) }
    let(:regular_transactions) { build_list(:regular_transaction, 1, :council_tax, amount: 300, frequency: "monthly") }
    let(:cash_transactions) do
      build_list(:cash_transaction, 3, category: :council_tax, operation: :debit, amount: 200)
    end

    context "before MTR" do
      let(:submission_date) { Date.new(2023, 4, 20) }

      it "has the council tax value 0" do
        expect(council_tax).to have_attributes(bank: 0, cash: 0, regular: 0, all_sources: 0)
      end
    end

    context "after MTR" do
      let(:submission_date) { Date.new(2525, 4, 20) }

      it "has the council tax value" do
        expect(council_tax).to have_attributes(bank: 100, cash: 200, regular: 300, all_sources: 600)
      end
    end
  end
end
