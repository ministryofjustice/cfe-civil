module Calculators
  class MultipleEmploymentsCalculator
    class << self
      def call(employments:, submission_date:)
        # multiple employments ignores inputs - hence inputs are reflected here as a set of dummy zero figures
        EmploymentIncomeCalculator::EmploymentResult.new(
          employments: employments.map do |e|
            DummyEmploymentFigures.new(monthly_gross_income: 0,
                                       monthly_benefits_in_kind: 0,
                                       employment_name: e.employment_name,
                                       employment_payments: e.employment_payments,
                                       monthly_tax: 0,
                                       monthly_national_insurance: 0,
                                       monthly_prisoner_levy: 0,
                                       monthly_student_debt_repayment: 0)
          end,
          result: EmploymentIncomeCalculator::Result.new(fixed_employment_allowance: fixed_employment_allowance(submission_date)),
        )
      end

    private

      DummyEmploymentFigures = Data.define(:monthly_gross_income, :monthly_benefits_in_kind, :monthly_tax,
                                           :monthly_national_insurance, :monthly_prisoner_levy, :monthly_student_debt_repayment, :employment_name, :employment_payments) do
        def entitles_employment_allowance?
          true
        end

        def entitles_childcare_allowance?
          true
        end
      end

      def fixed_employment_allowance(submission_date)
        -Threshold.value_for(:fixed_employment_allowance, at: submission_date)
      end
    end
  end
end
