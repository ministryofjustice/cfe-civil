class EmploymentIncomeSubtotals
  class << self
    def blank
      new monthly_gross_income: 0, benefits_in_kind: 0,
          fixed_employment_allowance: 0, tax: 0, national_insurance: 0
    end
  end

  def initialize(monthly_gross_income:, benefits_in_kind:,
                 fixed_employment_allowance:, tax:, national_insurance:)
    @monthly_gross_income = monthly_gross_income
    @benefits_in_kind = benefits_in_kind
    @fixed_employment_allowance = fixed_employment_allowance
    @tax = tax
    @national_insurance = national_insurance
  end

  attr_reader :benefits_in_kind,
              :fixed_employment_allowance,
              :tax,
              :national_insurance

  def gross_employment_income
    @monthly_gross_income + benefits_in_kind
  end

  def net_employment_income
    gross_employment_income + employment_income_deductions + fixed_employment_allowance
  end

  def employment_income_deductions
    tax + national_insurance
  end
end
