module Calculators
  class PensionContributionCalculator
    Result = Data.define(:bank, :cash, :regular) do
      def all_sources
        bank + cash + regular
      end

      def self.blank
        new(bank: 0, cash: 0, regular: 0)
      end
    end

    class << self
      def call(outgoings:, cash_transactions:, regular_transactions:, submission_date:, total_gross_income:)
        if (outgoings + cash_transactions + regular_transactions).any?
          monthly_bank = Calculators::MonthlyEquivalentCalculator.call(collection: outgoings)
          monthly_cash = Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
          monthly_regular = Calculators::MonthlyRegularTransactionAmountCalculator.result_for_transactions(regular_transactions)
          monthly_source_total = monthly_bank + monthly_cash + monthly_regular
          total = pension_contribution_cap(
            submission_date:,
            total_gross_income:,
            monthly_pension_contribution: monthly_source_total,
          )
          multiplicand = (total / monthly_source_total)
          Result.new(bank: (monthly_bank * multiplicand).round(2), cash: (monthly_cash * multiplicand).round(2), regular: (monthly_regular * multiplicand).round(2))
        else
          Result.blank
        end
      end

    private

      def pension_contribution_cap(total_gross_income:, submission_date:, monthly_pension_contribution:)
        if thresholds(submission_date).present?
          pension_contribution_cap = (total_gross_income * pension_contribution_cap_pctg(submission_date)).round(2)
          monthly_pension_contribution > pension_contribution_cap ? pension_contribution_cap : monthly_pension_contribution
        else
          0
        end
      end

      def pension_contribution_cap_pctg(submission_date)
        thresholds(submission_date) / 100.0
      end

      def thresholds(submission_date)
        Threshold.value_for(:pension_contribution_cap, at: submission_date)
      end
    end
  end
end
