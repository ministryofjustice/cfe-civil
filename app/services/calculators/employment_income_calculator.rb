module Calculators
  class EmploymentIncomeCalculator
    class << self
      def call(submission_date:, employment:)
        EmploymentIncomeSubtotals.new(gross_employment_income: employment.monthly_gross_income,
                                      benefits_in_kind: employment.monthly_benefits_in_kind,
                                      fixed_employment_allowance: allowance(employment, submission_date),
                                      tax: employment.monthly_tax,
                                      national_insurance: employment.monthly_national_insurance)
      end

    private

      def allowance(employment, submission_date)
        if employment.actively_working?
          fixed_employment_allowance submission_date
        else
          0.0
        end
      end

      def fixed_employment_allowance(submission_date)
        -Threshold.value_for(:fixed_employment_allowance, at: submission_date)
      end
    end
  end
end
