module Calculators
  class DependantAllowanceCalculator
    def self.call(dependant, submission_date)
      new(dependant, submission_date).call
    end

    def initialize(dependant, submission_date)
      @dependant = dependant
      @submission_date = submission_date
    end

    def call
      return child_under_15_allowance if @dependant.under_15_years_old?

      return child_under_16_allowance if @dependant.under_16_years_old?

      return under_18_in_full_time_education_allowance if @dependant.under_18_in_full_time_education?

      return 0.0 if capital_over_allowance?

      positive_or_zero(adult_allowance - monthly_income)
    end

  private

    attr_reader :submission_date

    def positive_or_zero(value)
      [0, value].max
    end

    def child_under_16_allowance
      positive_or_zero(child_aged_15_allowance - monthly_income)
    end

    def under_18_in_full_time_education_allowance
      positive_or_zero(child_16_and_over_allowance - monthly_income)
    end

    def monthly_income
      Calculators::MonthlyIncomeConverter.new(@dependant.frequency.to_sym, [@dependant.amount]).monthly_amount
    end

    def capital_over_allowance?
      @dependant.assets_value > adult_dependant_allowance_capital_threshold
    end

    def child_under_15_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_under_15]
    end

    def child_aged_15_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_aged_15]
    end

    def child_16_and_over_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:child_16_and_over]
    end

    def adult_allowance
      Threshold.value_for(:dependant_allowances, at: submission_date)[:adult]
    end

    def adult_dependant_allowance_capital_threshold
      Threshold.value_for(:dependant_allowances, at: submission_date)[:adult_capital_threshold]
    end
  end
end
