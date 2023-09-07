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
      if @dependant.under_15_years_old?
        positive_or_zero(thresholds[:child_under_15] - monthly_income)
      elsif @dependant.under_16_years_old?
        positive_or_zero(thresholds[:child_aged_15] - monthly_income)
      elsif @dependant.under_18_in_full_time_education?
        positive_or_zero(thresholds[:child_16_and_over] - monthly_income)
      elsif capital_over_allowance?
        0.0
      else
        positive_or_zero(thresholds[:adult] - monthly_income)
      end
    end

  private

    attr_reader :submission_date

    def positive_or_zero(value)
      [0, value].max
    end

    def monthly_income
      Utilities::MonthlyAmountConverter.call(@dependant.income_frequency, @dependant.income_amount)
    end

    def capital_over_allowance?
      @dependant.assets_value > thresholds[:adult_capital_threshold]
    end

    def thresholds
      Threshold.value_for(:dependant_allowances, at: submission_date)
    end
  end
end
