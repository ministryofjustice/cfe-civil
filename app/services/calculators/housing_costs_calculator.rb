module Calculators
  class HousingCostsCalculator
    Result = Data.define(:gross_housing_costs, :net_housing_costs, :gross_housing_costs_bank, :gross_housing_costs_cash, :gross_housing_costs_regular)

    class << self
      def call(housing_cost_outgoings:, gross_income_summary:, submission_date:, housing_costs_cap_applies:, monthly_housing_benefit:)
        # Because this code uses #allowable_amount, tbe 'bank' value has already been halved during the calculation
        # if the outgoing amount is of type 'board_and_lodging'
        gross_housing_costs_bank = gross_housing_costs_bank(housing_cost_outgoings)

        # we may have to halve the other amounts too - they don't have a 'housing cost type' associated with them, but we do a 'best effort'
        # and assume that they are all of the same type if the 'outgoings' are all board_and_lodging type
        if should_halve_full_cost_minus_benefits?(housing_cost_outgoings, monthly_housing_benefit)
          gross_housing_costs_regular_transactions = gross_housing_costs_regular_transactions(gross_income_summary) / 2
          gross_housing_costs_cash = gross_housing_costs_cash(gross_income_summary) / 2
        else
          gross_housing_costs_regular_transactions = gross_housing_costs_regular_transactions(gross_income_summary)
          gross_housing_costs_cash = gross_housing_costs_cash(gross_income_summary)
        end

        gross_housing_costs = gross_housing_costs_bank + gross_housing_costs_regular_transactions + gross_housing_costs_cash

        Result.new gross_housing_costs:,
                   net_housing_costs: net_housing_costs(submission_date:, housing_costs_cap_applies:,
                                                        monthly_housing_benefit:, gross_housing_costs:),
                   gross_housing_costs_bank:,
                   gross_housing_costs_cash:,
                   gross_housing_costs_regular: gross_housing_costs_regular_transactions
      end

    private

      def net_housing_costs(submission_date:, housing_costs_cap_applies:, monthly_housing_benefit:, gross_housing_costs:)
        if housing_costs_cap_applies
          [gross_housing_costs,
           gross_housing_costs - monthly_housing_benefit,
           single_monthly_housing_costs_cap(submission_date)].min
        else
          gross_housing_costs - monthly_housing_benefit
        end
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

      def all_board_and_lodging?(housing_cost_outgoings)
        housing_cost_outgoings.any? && housing_cost_outgoings.all?(&:board_and_lodging?)
      end

      def should_halve_full_cost_minus_benefits?(housing_cost_outgoings, monthly_housing_benefits)
        monthly_housing_benefits.positive? && all_board_and_lodging?(housing_cost_outgoings)
      end

      def single_monthly_housing_costs_cap(submission_date)
        Threshold.value_for(:single_monthly_housing_costs_cap, at: submission_date)
      end
    end
  end
end
