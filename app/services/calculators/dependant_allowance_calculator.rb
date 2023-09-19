module Calculators
  class DependantAllowanceCalculator
    class << self
      def call(dependant, submission_date)
        thresholds = Threshold.value_for(:dependant_allowances, at: submission_date)
        monthly_income = Utilities::MonthlyAmountConverter.call(dependant.income_frequency, dependant.income_amount)

        if dependant.under_14_years_old? && thresholds.key?(:child_under_14)
          Utilities::NumberUtilities.negative_to_zero(thresholds[:child_under_14] - monthly_income)
        elsif dependant.under_15_years_old?
          Utilities::NumberUtilities.negative_to_zero(thresholds[:child_under_15] - monthly_income)
        elsif dependant.under_16_years_old?
          Utilities::NumberUtilities.negative_to_zero(thresholds[:child_aged_15] - monthly_income)
        elsif dependant.under_18_in_full_time_education?
          Utilities::NumberUtilities.negative_to_zero(thresholds[:child_16_and_over] - monthly_income)
        elsif dependant.assets_value > thresholds[:adult_capital_threshold]
          0.0
        else
          Utilities::NumberUtilities.negative_to_zero(thresholds[:adult] - monthly_income)
        end
      end
    end
  end
end
