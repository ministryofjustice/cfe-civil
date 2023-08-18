module Collators
  class DisposableIncomeCollator
    Result = Data.define(:rent_or_mortgage_cash, :legal_aid_cash, :maintenance_out_cash) do
      def self.blank
        new(rent_or_mortgage_cash: 0, legal_aid_cash: 0, maintenance_out_cash: 0)
      end
    end

    class << self
      def call(disposable_income_summary:, gross_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:)
        new(gross_income_summary:, disposable_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:).call
      end
    end

    def initialize(disposable_income_summary:, gross_income_summary:, partner_allowance:, gross_income_subtotals:, outgoings:)
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @partner_allowance = partner_allowance
      @gross_income_subtotals = gross_income_subtotals
      @outgoings = outgoings
    end

    def call
      Result.new(legal_aid_cash: monthly_cash_by_category(:legal_aid),
                 maintenance_out_cash: monthly_cash_by_category(:maintenance_out),
                 rent_or_mortgage_cash: monthly_cash_by_category(:rent_or_mortgage))
    end

    def monthly_cash_by_category(category)
      cash_transactions = @gross_income_summary.cash_transactions(:debit, category)
      Calculators::MonthlyCashTransactionAmountCalculator.call(cash_transactions)
    end
  end
end
