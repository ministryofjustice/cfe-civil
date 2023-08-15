module Collators
  class DisposableIncomeCollator
    Attrs = Data.define(:monthly_cash_transactions_total, :rent_or_mortgage_cash, :legal_aid_cash, :maintenance_out_cash)
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
      attrs = populate_attrs
      @disposable_income_summary.update!(
        total_outgoings_and_allowances: total_outgoings_and_allowances(attrs.monthly_cash_transactions_total),
        total_disposable_income: disposable_income(attrs.monthly_cash_transactions_total),
      )

      Result.new(rent_or_mortgage_cash: attrs.rent_or_mortgage_cash, legal_aid_cash: attrs.legal_aid_cash, maintenance_out_cash: attrs.maintenance_out_cash)
    end

  private

    def populate_attrs
      maintenance_out_cash_amount = monthly_cash_by_category(:maintenance_out)

      legal_aid_cash_amount = monthly_cash_by_category(:legal_aid)

      Attrs.new(legal_aid_cash: legal_aid_cash_amount,
                maintenance_out_cash: maintenance_out_cash_amount,
                rent_or_mortgage_cash: monthly_cash_by_category(:rent_or_mortgage),
                monthly_cash_transactions_total: maintenance_out_cash_amount + @outgoings.child_care.cash + legal_aid_cash_amount)
    end

    def monthly_cash_by_category(category)
      cash_transactions = @gross_income_summary.cash_transactions(:debit, category)
      Calculators::MonthlyCashTransactionAmountCalculator.call(cash_transactions)
    end

    def total_outgoings_and_allowances(monthly_cash_transactions_total)
      @outgoings.housing_costs.net_housing_costs +
        @outgoings.dependant_allowance.under_16 +
        @outgoings.dependant_allowance.over_16 +
        monthly_bank_transactions_total +
        monthly_cash_transactions_total -
        @gross_income_subtotals.employment_income_subtotals.fixed_employment_allowance -
        @gross_income_subtotals.employment_income_subtotals.employment_income_deductions +
        @partner_allowance
    end

    def monthly_bank_transactions_total
      @outgoings.child_care.bank +
        @outgoings.maintenance_out_bank +
        @outgoings.legal_aid_bank
    end

    def disposable_income(monthly_cash_transactions_total)
      @gross_income_subtotals.total_gross_income - total_outgoings_and_allowances(monthly_cash_transactions_total)
    end
  end
end
