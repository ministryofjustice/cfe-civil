module Calculators
  class PensionerCapitalDisregardCalculator
    class << self
      def passported_value(submission_date:, date_of_birth:)
        if pensioner?(submission_date:, date_of_birth:)
          thresholds(submission_date)[:passported]
        else
          0
        end
      end

      def non_passported_value(submission_date:, date_of_birth:, total_disposable_income:)
        if pensioner?(submission_date:, date_of_birth:)
          income = total_disposable_income.to_f
          thresholds(submission_date)[:monthly_income_values].detect { |value_bands, _banding| income_threshold_applies?(income, value_bands) }.second
        else
          0
        end
      end

    private

      def pensioner?(submission_date:, date_of_birth:)
        if thresholds(submission_date)[:minimum_age_in_years] == "state_pension_age"
          submission_date > Calculators::StatePensionDateCalculator.state_pension_date(date_of_birth:)
        else
          earliest_dob_for_pensioner(submission_date) >= date_of_birth
        end
      end

      def earliest_dob_for_pensioner(submission_date)
        submission_date - thresholds(submission_date)[:minimum_age_in_years].years
      end

      def income_threshold_applies?(income, key_array)
        (key_array.count.eql?(1) && income >= key_array[0]) || (income >= key_array[0] && income <= key_array[1])
      end

      def thresholds(submission_date)
        Threshold.value_for(:pensioner_capital_disregard, at: submission_date)
      end
    end
  end
end
