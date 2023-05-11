module Calculators
  class MultipleEmploymentsCalculator
    def self.call(submission_date:, employments:)
      new(submission_date:, employments:).call
    end

    def initialize(submission_date:, employments:)
      @employments = employments
      @submission_date = submission_date
    end

    def call
      EmploymentIncomeSubtotals.new(
        monthly_gross_income: gross_income_values.fetch(:monthly_gross_income),
        benefits_in_kind: gross_income_values.fetch(:benefits_in_kind),
        tax: disposable_income_values.fetch(:tax),
        national_insurance: disposable_income_values.fetch(:national_insurance),
        fixed_employment_allowance: disposable_income_values.fetch(:fixed_employment_allowance),
      ).freeze
    end

  private

    def gross_income_values
      {
        monthly_gross_income: 0.0,
        benefits_in_kind: 0.0,
      }
    end

    def disposable_income_values
      {
        tax: 0.0,
        national_insurance: 0.0,
        fixed_employment_allowance: -Threshold.value_for(:fixed_employment_allowance, at: @submission_date),
      }
    end
  end
end
