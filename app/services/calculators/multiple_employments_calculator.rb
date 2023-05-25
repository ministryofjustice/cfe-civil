module Calculators
  class MultipleEmploymentsCalculator
    class << self
      def call(submission_date)
        EmploymentIncomeSubtotals.new(
          gross_employment_income: 0.0,
          benefits_in_kind: 0.0,
          tax: 0.0,
          national_insurance: 0.0,
          fixed_employment_allowance: fixed_employment_allowance(submission_date),
        )
      end

    private

      def fixed_employment_allowance(submission_date)
        -Threshold.value_for(:fixed_employment_allowance, at: submission_date)
      end
    end
  end
end
