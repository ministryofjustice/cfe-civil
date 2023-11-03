require "rails_helper"

describe CashTransaction do
  let(:assessment1) { create :assessment, :with_gross_income_summary_and_records }
  let(:assessment2) { create :assessment, :with_gross_income_summary_and_records }
  let(:benefits_category1) { assessment1.applicant_gross_income_summary.cash_transaction_categories.detect { |cat| cat.name == "benefits" } }
  let(:benefits_category2) { assessment2.applicant_gross_income_summary.cash_transaction_categories.detect { |cat| cat.name == "benefits" } }
  let!(:benefits_transactions1) { benefits_category1.cash_transactions.order(:date) }
  let!(:benefits_transactions2) { benefits_category2.cash_transactions.order(:date) }

  describe "by_operation_and_category" do
    it "display all the cash transactions for benefits 1" do
      expect(assessment1.applicant_gross_income_summary.cash_transactions.by_operation_and_category(:credit, :benefits)).to match_array benefits_transactions1
    end

    it "display all the cash transactions for benefits 2" do
      expect(assessment2.applicant_gross_income_summary.cash_transactions.by_operation_and_category(:credit, :benefits)).to match_array benefits_transactions2
    end
  end
end
