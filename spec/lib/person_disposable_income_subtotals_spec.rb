# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PersonDisposableIncomeSubtotals" do
  let(:assessment) do
    create(:assessment, :with_disposable_income_summary, :with_gross_income_summary,
           submission_date: Date.new(2525, 4, 20))
  end

  describe "#pension_contribution_bank" do
    let(:subtotals) do
      PersonDisposableIncomeSubtotals.new(gross_income_subtotals: instance_double(PersonGrossIncomeSubtotals, total_gross_income: 1000),
                                          outgoings: nil,
                                          partner_allowance: 0,
                                          regular: nil,
                                          disposable: nil,
                                          pension_contributions:,
                                          pension_cash_transactions: [],
                                          pension_regular_transactions: [],
                                          submission_date: assessment.submission_date)
    end
    let(:pension_contributions) do
      create_list(:pension_contribution_outgoing, 3, amount: monthly_contribution)
    end

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 51 }

      it "has the threshold value" do
        expect(subtotals.pension_contribution_bank).to eq(50)
      end
    end

    context "below threshold" do
      let(:monthly_contribution) { 49 }

      it "has the pension contribs value" do
        expect(subtotals.pension_contribution_bank).to eq(49)
      end
    end
  end

  describe "#pension_contribution_cash" do
    let(:pension_contributions) do
      ctc = create(:cash_transaction_category, name: "pension_contribution", operation: :debit, gross_income_summary: assessment.applicant_gross_income_summary)
      create_list(:cash_transaction, 3, cash_transaction_category: ctc, amount: monthly_contribution)
    end

    let(:subtotals) do
      PersonDisposableIncomeSubtotals.new(gross_income_subtotals: instance_double(PersonGrossIncomeSubtotals, total_gross_income: 1000),
                                          outgoings: nil,
                                          partner_allowance: 0,
                                          regular: nil,
                                          disposable: nil,
                                          pension_contributions: [],
                                          pension_cash_transactions: pension_contributions,
                                          pension_regular_transactions: [],
                                          submission_date: assessment.submission_date)
    end

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 51 }

      it "has the threshold value" do
        expect(subtotals.pension_contribution_cash).to eq(50)
      end
    end

    context "below threshold" do
      let(:monthly_contribution) { 49 }

      it "has the pension contribs value" do
        expect(subtotals.pension_contribution_cash).to eq(49)
      end
    end
  end

  describe "#pension_contribution_regular" do
    let(:pension_contributions) do
      create_list(:regular_transaction, 3, :pension_contribution, gross_income_summary: assessment.applicant_gross_income_summary, amount: monthly_contribution)
    end

    let(:subtotals) do
      PersonDisposableIncomeSubtotals.new(gross_income_subtotals: instance_double(PersonGrossIncomeSubtotals, total_gross_income: 1000),
                                          outgoings: nil,
                                          partner_allowance: 0,
                                          regular: nil,
                                          disposable: nil,
                                          pension_contributions: [],
                                          pension_cash_transactions: [],
                                          pension_regular_transactions: pension_contributions,
                                          submission_date: assessment.submission_date)
    end

    context "when exceeding the 5% gross income threshold" do
      let(:monthly_contribution) { 51 }

      it "has the threshold value" do
        expect(subtotals.pension_contribution_regular).to eq(50)
      end
    end

    context "below threshold" do
      let(:monthly_contribution) { 49 }

      it "has the pension contribs value" do
        expect(subtotals.pension_contribution_regular).to eq(49)
      end
    end
  end
end
