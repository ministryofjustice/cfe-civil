require "rails_helper"

RSpec.describe "Calculators::PensionContributionCalculator", :calls_bank_holiday do
  around do |example|
    travel_to submission_date
    example.run
    travel_back
  end

  let(:submission_date) { Date.new(2525, 4, 20) }
  let(:assessment) do
    create(:assessment, :with_disposable_income_summary, :with_gross_income_summary,
           submission_date:)
  end
  let(:pension) do
    Calculators::PensionContributionCalculator.call(
      outgoings: pension_outgoings,
      cash_transactions: pension_cash_transactions,
      regular_transactions: pension_regular_transactions,
      submission_date: assessment.submission_date,
      total_gross_income: 1200,
    )
  end

  describe "#pension_contributions" do
    let(:pension_outgoings) { build_list(:pension_contribution_outgoing, 3, amount: monthly_contribution) }
    let(:pension_cash_transactions) do
      build_list(:cash_transaction, 3, category: :pension_contribution, operation: :debit, amount: monthly_contribution)
    end
    let(:pension_regular_transactions) { [] }

    context "below threshold" do
      let(:monthly_contribution) { 10 }

      it "has the pension contribution value" do
        expect(pension).to have_attributes(bank: 10, cash: 10, regular: 0, all_sources: 20)
      end
    end

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 45 }

      it "has the threshold value" do
        expect(pension).to have_attributes(bank: 30, cash: 30, regular: 0, all_sources: 60)
      end
    end
  end

  describe "#pension_contribution_cash" do
    let(:pension_cash_transactions) do
      build_list(:cash_transaction, 3, category: :pension_contribution, operation: :debit, amount: monthly_contribution)
    end
    let(:pension_outgoings) { [] }
    let(:pension_regular_transactions) { [] }

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 61 }

      it "has the threshold value" do
        expect(pension).to have_attributes(bank: 0, cash: 60, regular: 0, all_sources: 60)
      end
    end

    context "below threshold" do
      let(:monthly_contribution) { 49 }

      it "has the pension contribution value" do
        expect(pension).to have_attributes(bank: 0, cash: 49, regular: 0, all_sources: 49)
      end
    end
  end

  describe "#pension_contribution_regular" do
    let(:pension_regular_transactions) do
      build_list(:regular_transaction, 1, :pension_contribution, amount: monthly_contribution, frequency: "monthly")
    end
    let(:pension_outgoings) { [] }
    let(:pension_cash_transactions) { [] }

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 61 }

      it "has the threshold value" do
        expect(pension).to have_attributes(bank: 0, cash: 0, regular: 60, all_sources: 60)
      end
    end

    context "below threshold" do
      let(:monthly_contribution) { 49 }

      it "has the pension contribution value" do
        expect(pension).to have_attributes(bank: 0, cash: 0, regular: 49, all_sources: 49)
      end
    end
  end

  context "with no contributions" do
    let(:pension_regular_transactions) { [] }
    let(:pension_outgoings) { [] }
    let(:pension_cash_transactions) { [] }

    it "contains zeroes" do
      expect(pension).to have_attributes(bank: 0, cash: 0, regular: 0)
    end
  end
end
