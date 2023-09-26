# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PersonDisposableIncomeSubtotals" do
  let(:assessment) do
    create(:assessment, :with_disposable_income_summary, :with_gross_income_summary,
           submission_date: Date.new(2525, 4, 20))
  end

  let(:subtotals) do
    PersonDisposableIncomeSubtotals.new(gross_income_subtotals: instance_double(PersonGrossIncomeSubtotals, total_gross_income: 1000),
                                        outgoings: instance_double(Collators::OutgoingsCollator::Result, pension_contribution:),
                                        partner_allowance: 0,
                                        regular: nil,
                                        disposable: nil,
                                        submission_date: assessment.submission_date)
  end

  describe "#pension_contribution_bank" do
    let(:pension_contribution) do
      Collators::PensionContributionCollator.call(
        outgoings: pension_contributions,
        cash_transactions: [],
        regular_transactions: [],
      )
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

    let(:pension_contribution) do
      Collators::PensionContributionCollator.call(
        outgoings: [],
        cash_transactions: pension_contributions,
        regular_transactions: [],
      )
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

    let(:pension_contribution) do
      Collators::PensionContributionCollator.call(
        outgoings: [],
        cash_transactions: [],
        regular_transactions: pension_contributions,
      )
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
