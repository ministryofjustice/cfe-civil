module Calculators
  class MultipleEmploymentsCalculator
    class << self
      def call(submission_date)
        # multiple employments ignores inputs - hence inputs are reflected here as a set of dummy zero figures
        EmploymentIncomeCalculator::EmploymentResult.new(
          employment: DummyEmploymentFigures.new(0, 0, 0, 0),
          result: EmploymentIncomeCalculator::Result.new(fixed_employment_allowance: fixed_employment_allowance(submission_date)),
        )
      end

    private

      DummyEmploymentFigures = Data.define(:monthly_gross_income, :monthly_benefits_in_kind, :monthly_tax, :monthly_national_insurance) do
        def entitles_employment_allowance?
          true
        end

        def entitles_childcare_allowance?
          false
        end
      end

      def fixed_employment_allowance(submission_date)
        -Threshold.value_for(:fixed_employment_allowance, at: submission_date)
      end
    end
  end
end
