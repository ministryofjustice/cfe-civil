module Calculators
  class EmploymentIncomeCalculator
    EmploymentResult = Data.define(:employment, :result)
    Result = Data.define(:fixed_employment_allowance)

    class << self
      def call(submission_date:, employment:)
        EmploymentResult.new(employment:,
                             result: Result.new(fixed_employment_allowance: allowance(employment, submission_date)))
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
