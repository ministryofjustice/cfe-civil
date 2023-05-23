module Calculators
  class EmploymentIncomeCalculator
    def self.call(submission_date:, employment:)
      new(submission_date:, employment:).call
    end

    def initialize(submission_date:, employment:)
      @submission_date = submission_date
      @employment = employment
    end

    def call
      EmploymentIncomeSubtotals.new(gross_employment_income: monthly_incomes,
                                    benefits_in_kind: monthly_benefits_in_kind,
                                    fixed_employment_allowance: allowance,
                                    tax: taxes,
                                    national_insurance: ni_contributions).freeze
    end

  private

    def monthly_incomes
      @employment&.monthly_gross_income || 0.0
    end

    def monthly_benefits_in_kind
      @employment&.monthly_benefits_in_kind || 0.0
    end

    def taxes
      @employment&.monthly_tax || 0.0
    end

    def ni_contributions
      @employment&.monthly_national_insurance || 0.0
    end

    def allowance
      if @employment&.actively_working?
        fixed_employment_allowance
      else
        0.0
      end
    end

    def fixed_employment_allowance
      -Threshold.value_for(:fixed_employment_allowance, at: @submission_date)
    end
  end
end
