module Calculators
  class HousingCostsCalculator
    Result = Data.define(:housing_costs, :allowed_housing_costs, :housing_costs_bank, :housing_costs_cash, :housing_costs_regular)

    class << self
      def call(housing_cost_outgoings:, gross_income_summary:, submission_date:, housing_costs_cap_applies:, monthly_housing_benefit:, regular_transactions:)
        # 'Board and lodging' adjustment has already taken place in :allowable_amount
        housing_costs_bank = Calculators::MonthlyEquivalentCalculator.call(
          collection: housing_cost_outgoings,
          amount_method: :allowable_amount,
        )

        # 'Board and lodging' adjustments - Where outgoings are for 'board and lodging' (rather then rent/mortgage) then only half the
        # outgoing can be 'allowed housing costs' (i.e. the meals element is not an allowable deduction)
        # (see Lord Chancellors' Guidance (certificated) 5.5 'Housing costs' paragraph 7)
        # Unlike 'bank' housing costs, 'regular' and 'cash' housing costs don't have a 'housing cost type' associated with them,
        # so to decide whether to halve them, we do a 'best effort' by assuming they are board_and_lodging if the 'bank' housing costs
        # are of board_and_lodging type
        if should_halve_full_cost_minus_benefits?(housing_cost_outgoings, monthly_housing_benefit)
          housing_costs_regular = housing_costs_regular_transactions(regular_transactions) / 2
          housing_costs_cash = housing_costs_cash(gross_income_summary) / 2
        else
          housing_costs_regular = housing_costs_regular_transactions(regular_transactions)
          housing_costs_cash = housing_costs_cash(gross_income_summary)
        end

        housing_costs = housing_costs_bank + housing_costs_regular + housing_costs_cash

        # Housing benefit
        housing_benefit_to_subtract = if allowed_housing_costs_are_net_of_housing_benefit?(submission_date)
                                        # Pre-MTR: Allowed housing costs are NET of housing benefit
                                        # i.e. when calculating allowed_housing_costs we'll subtract the housing benefit amount
                                        monthly_housing_benefit
                                      else
                                        # Post-MTR: nothing needs to be subtracted from housing costs when calculating allowed_housing_costs
                                        0
                                      end

        Result.new housing_costs:,
                   allowed_housing_costs: allowed_housing_costs(submission_date:, housing_costs_cap_applies:,
                                                                housing_benefit_to_subtract:, housing_costs:),
                   housing_costs_bank:,
                   housing_costs_cash:,
                   housing_costs_regular:
      end

    private

      def allowed_housing_costs(submission_date:, housing_costs_cap_applies:, housing_benefit_to_subtract:, housing_costs:)
        if housing_costs_cap_applies
          [housing_costs,
           housing_costs - housing_benefit_to_subtract,
           single_monthly_housing_costs_cap(submission_date)].min
        else
          housing_costs - housing_benefit_to_subtract
        end
      end

      def allowed_housing_costs_are_net_of_housing_benefit?(submission_date)
        # - True pre-MTR
        # - False post-MTR
        # i.e. the opposite of housing_benefit_included_in_gross_income
        !StateBenefitsCalculator.housing_benefit_included_in_gross_income?(submission_date)
      end

      def housing_costs_cash(gross_income_summary)
        cash_transactions = gross_income_summary.cash_transactions.by_operation_and_category(:debit, :rent_or_mortgage)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
      end

      def housing_costs_regular_transactions(regular_transactions)
        txns = regular_transactions.select(&:rent_or_mortgage?)
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
