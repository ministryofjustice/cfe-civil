module Calculators
  class HousingCostsCalculator
    Result = Data.define(:gross_housing_costs, :net_housing_costs, :monthly_housing_benefit, :gross_housing_costs_bank)
    class << self
      def call(housing_cost_outgoings:, gross_income_summary:, submission_date:, housing_cost_cap:)
        Result.new gross_housing_costs: gross_housing_costs(gross_income_summary, housing_cost_outgoings),
                   net_housing_costs: net_housing_costs(gross_income_summary:, housing_cost_outgoings:, submission_date:, housing_cost_cap_applies: housing_cost_cap),
                   monthly_housing_benefit: monthly_housing_benefit(gross_income_summary),
                   gross_housing_costs_bank: gross_housing_costs_bank(housing_cost_outgoings)
      end

    private

      def net_housing_costs(gross_income_summary:, housing_cost_outgoings:, submission_date:, housing_cost_cap_applies:)
        if housing_cost_cap_applies
          [gross_housing_costs(gross_income_summary, housing_cost_outgoings),
           gross_cost_minus_housing_benefit(gross_income_summary, housing_cost_outgoings),
           single_monthly_housing_costs_cap(submission_date)].min
        elsif should_halve_full_cost_minus_benefits?(gross_income_summary, housing_cost_outgoings)
          (monthly_actual_housing_costs(gross_income_summary, housing_cost_outgoings) - monthly_housing_benefit(gross_income_summary)) / 2
        else
          gross_cost_minus_housing_benefit gross_income_summary, housing_cost_outgoings
        end
      end

      def gross_housing_costs(gross_income_summary, housing_cost_outgings)
        gross_housing_costs_bank(housing_cost_outgings) +
          gross_housing_costs_regular_transactions(gross_income_summary) +
          gross_housing_costs_cash(gross_income_summary)
      end

      def monthly_housing_benefit(gross_income_summary)
        housing_benefit_payments = Calculators::MonthlyEquivalentCalculator.call(
          collection: housing_benefit_records(gross_income_summary),
        )
        housing_benefit_payments + monthly_housing_benefit_regular_transactions(gross_income_summary)
      end

      def gross_housing_costs_bank(housing_cost_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(
          collection: housing_cost_outgoings,
          amount_method: :allowable_amount,
        )
      end

      def gross_housing_costs_cash(gross_income_summary)
        cash_transactions = gross_income_summary.cash_transactions(:debit, :rent_or_mortgage)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
      end

      def gross_housing_costs_regular_transactions(gross_income_summary)
        txns = gross_income_summary.regular_transactions.with_operation_and_category(:debit, :rent_or_mortgage)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end

      def monthly_housing_benefit_regular_transactions(gross_income_summary)
        txns = gross_income_summary.regular_transactions.with_operation_and_category(:credit, :housing_benefit)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end

      # TODO: regular transactions may need accounting for here at some point
      # but at time of writing they do not include sub-types of housing costs,
      # specifically "board and lodging", so this should never get called.
      def monthly_actual_housing_costs(gross_income_summary, housing_cost_outgoings)
        actual_housing_costs(housing_cost_outgoings) + gross_housing_costs_cash(gross_income_summary)
      end

      def actual_housing_costs(housing_cost_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: housing_cost_outgoings)
      end

      def gross_cost_minus_housing_benefit(gross_income_summary, housing_cost_outgings)
        gross_housing_costs(gross_income_summary, housing_cost_outgings) - monthly_housing_benefit(gross_income_summary)
      end

      def housing_benefit_records(gross_income_summary)
        gross_income_summary.housing_benefit_payments
      end

      def all_board_and_lodging?(housing_cost_outgoings)
        housing_cost_outgoings.any? && housing_cost_outgoings.all?(&:board_and_lodging?)
      end

      def should_halve_full_cost_minus_benefits?(gross_income_summary, housing_cost_outgoings)
        should_exclude_housing_benefit?(gross_income_summary) && all_board_and_lodging?(housing_cost_outgoings)
      end

      def should_exclude_housing_benefit?(gross_income_summary)
        receiving_housing_benefits? gross_income_summary
      end

      def receiving_housing_benefits?(gross_income_summary)
        gross_income_summary.housing_benefit_payments.present? ||
          monthly_housing_benefit_regular_transactions(gross_income_summary).positive?
      end

      def single_monthly_housing_costs_cap(submission_date)
        Threshold.value_for(:single_monthly_housing_costs_cap, at: submission_date)
      end
    end
  end
end
