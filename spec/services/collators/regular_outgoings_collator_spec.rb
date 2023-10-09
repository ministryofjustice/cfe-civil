require "rails_helper"

# regular_outgoings_transactions needs to:
# 1. work out monthly equivalent values for each category of debit operation
# 1. increment all _all_sources for each category of debit operation
# 2. increment total_outgoings_and_allowances, except for rent_or_mortgate**
# 3. decrement total_disposable_income, except for rent_or_mortgate**
#
# ** in full NonPassportedWorkflow :rent_or_mortgage will already been added
# to totals by the HousingCostCollator/HousingCostCalculator and DisposableIncomeCollator :(
#

RSpec.describe Collators::RegularOutgoingsCollator do
  let(:assessment) { create(:assessment, :with_gross_income_summary, :with_disposable_income_summary) }
  let(:gross_income_summary) { assessment.applicant_gross_income_summary }
  let(:eligible_for_childcare) { true }

  describe ".call" do
    subject(:collator) do
      described_class.call(gross_income_summary:, eligible_for_childcare:)
    end

    context "without monthly regular transactions" do
      it "does increments #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(legal_aid_regular: 0.0, maintenance_out_regular: 0.0)
      end
    end

    context "with monthly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "monthly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(legal_aid_regular: 222.22, maintenance_out_regular: 111.11)
      end
    end

    context "with four_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "four_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "four_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "four_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(legal_aid_regular: 240.74, maintenance_out_regular: 120.37)
      end
    end

    context "with two_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "two_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "two_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "two_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(legal_aid_regular: 481.48, maintenance_out_regular: 240.74)
      end
    end

    context "with weekly regular transaction" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(legal_aid_regular: 962.95, maintenance_out_regular: 481.48)
      end
    end

    # ** see above for reason
    context "with monthly regular transactions of :rent_or_mortgage" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 222.22)
      end

      it "increments #rent_or_mortgage_all_sources data" do
        expect(collator).to have_attributes(
          rent_or_mortgage_regular: 222.22,
          legal_aid_regular: 0.00,
          maintenance_out_regular: 0.0,
        )
      end
    end

    context "with monthly regular transaction of :child_care" do
      before do
        create(:regular_transaction,
               gross_income_summary:,
               operation: "debit",
               category: "child_care",
               frequency: "monthly", amount: 111.11)
      end

      context "when eligible for childcare" do
        it "returns #child_care_regular data" do
          expect(collator.child_care_regular).to eq(111.11)
        end
      end

      context "when not eligible for childcare" do
        let(:eligible_for_childcare) { false }

        it "ignores the value" do
          expect(collator.child_care_regular).to eq(0)
        end
      end
    end

    context "with multiple regular transactions of same operation and category" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 222.22)
      end

      it "increments their values into single #<cagtegory>_all_sources data" do
        expect(collator).to have_attributes(maintenance_out_regular: 333.33)
      end
    end

    context "with existing data" do
      context "with monthly regular transactions" do
        before do
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 1000.00)
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "monthly", amount: 2000.00)
        end

        it "increments #<category>_all_sources data to existing values" do
          expect(collator).to have_attributes(legal_aid_regular: 2_000.00, maintenance_out_regular: 1000.00)
        end
      end
    end
  end
end
