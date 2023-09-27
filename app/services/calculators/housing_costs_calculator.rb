module Calculators
  class HousingCostsCalculator
    def initialize(housing_cost_outgoings:, gross_income_summary:, submission_date:, person:)
      @housing_cost_outgoings = housing_cost_outgoings
      @gross_income_summary = gross_income_summary
      @submission_date = submission_date
      @person = person
    end

    def net_housing_costs
      if housing_costs_cap_apply?
        [gross_housing_costs, gross_cost_minus_housing_benefit, single_monthly_housing_costs_cap].min
      elsif should_halve_full_cost_minus_benefits?
        (monthly_actual_housing_costs - monthly_housing_benefit) / 2
      else
        gross_cost_minus_housing_benefit
      end
    end

    def gross_housing_costs
      @gross_housing_costs ||= gross_housing_costs_bank +
        gross_housing_costs_regular_transactions +
        gross_housing_costs_cash
    end

    def monthly_housing_benefit
      @monthly_housing_benefit ||= begin
        housing_benefit_payments = Calculators::MonthlyEquivalentCalculator.call(
          collection: housing_benefit_records,
        )
        housing_benefit_payments + monthly_housing_benefit_regular_transactions
      end
    end

    def gross_housing_costs_bank
      Calculators::MonthlyEquivalentCalculator.call(
        collection: @housing_cost_outgoings,
        amount_method: :allowable_amount,
      )
    end

  private

    def gross_housing_costs_cash
      cash_transactions = @gross_income_summary.cash_transactions(:debit, :rent_or_mortgage)
      Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
    end

    def gross_housing_costs_regular_transactions
      txns = @gross_income_summary.regular_transactions.with_operation_and_category(:debit, :rent_or_mortgage)
      Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
    end

    def monthly_housing_benefit_regular_transactions
      txns = @gross_income_summary.regular_transactions.with_operation_and_category(:credit, :housing_benefit)
      Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
    end

    # TODO: regular transactions may need accounting for here at some point
    # but at time of writing they do not include sub-types of housing costs,
    # specifically "board and lodging", so this should never get called.
    def monthly_actual_housing_costs
      @monthly_actual_housing_costs ||= actual_housing_costs + gross_housing_costs_cash
    end

    def actual_housing_costs
      Calculators::MonthlyEquivalentCalculator.call(collection: @housing_cost_outgoings)
    end

    def gross_cost_minus_housing_benefit
      gross_housing_costs - monthly_housing_benefit
    end

    def housing_benefit_records
      @gross_income_summary.housing_benefit_payments
    end

    def all_board_and_lodging?
      @housing_cost_outgoings.present? &&
        @housing_cost_outgoings.map(&:housing_cost_type).all?("board_and_lodging")
    end

    def should_halve_full_cost_minus_benefits?
      should_exclude_housing_benefit? && all_board_and_lodging?
    end

    def should_exclude_housing_benefit?
      receiving_housing_benefits?
    end

    def receiving_housing_benefits?
      @gross_income_summary.housing_benefit_payments.present? ||
        monthly_housing_benefit_regular_transactions.positive?
    end

    def single_monthly_housing_costs_cap
      Threshold.value_for(:single_monthly_housing_costs_cap, at: @submission_date)
    end

    def housing_costs_cap_apply?
      person_single? && person_has_no_dependants?
    end

    def person_single?
      @person.single?
    end

    def person_has_no_dependants?
      @person.dependants.none?
    end
  end
end
