module Calculators
  class PensionerCapitalDisregardCalculator
    class << self
      def passported_value(submission_date:, date_of_birth:)
        if pensioner?(submission_date:, date_of_birth:)
          thresholds(submission_date, :passported)
        else
          0
        end
      end

      def non_passported_value(submission_date:, date_of_birth:, total_disposable_income:)
        if pensioner?(submission_date:, date_of_birth:)
          income = total_disposable_income.to_f
          monthly_income_bands = thresholds(submission_date, :monthly_income_values)
          value_band_key = monthly_income_bands.keys.detect { |lower, upper| income.between?(lower, upper) }
          monthly_income_bands.fetch(value_band_key)
        else
          0
        end
      end

    private

      def pensioner?(submission_date:, date_of_birth:)
        if thresholds(submission_date, :minimum_age_in_years) == "state_pension_age"
          submission_date > Calculators::StatePensionDateCalculator.state_pension_date(date_of_birth:)
        else
          earliest_dob_for_pensioner(submission_date) >= date_of_birth
        end
      end

      def earliest_dob_for_pensioner(submission_date)
        submission_date - thresholds(submission_date, :minimum_age_in_years).years
      end

      def thresholds(submission_date, key)
        Threshold.value_for(:pensioner_capital_disregard, at: submission_date).fetch(key)
      end
    end
  end
end
