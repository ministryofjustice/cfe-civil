class EmploymentIncomeSubtotals
  class << self
    def blank
      new gross_employment_income: 0, benefits_in_kind: 0,
          fixed_employment_allowance: 0, tax: 0, national_insurance: 0
    end
  end

  def initialize(gross_employment_income:, benefits_in_kind:,
                 fixed_employment_allowance:, tax:, national_insurance:)
    @gross_employment_income = gross_employment_income
    @benefits_in_kind = benefits_in_kind
    @fixed_employment_allowance = fixed_employment_allowance
    @tax = tax
    @national_insurance = national_insurance
  end

  attr_reader :gross_employment_income,
              :benefits_in_kind,
              :fixed_employment_allowance,
              :tax,
              :national_insurance

  def net_employment_income
    gross_employment_income + benefits_in_kind + employment_income_deductions + fixed_employment_allowance
  end

  def employment_income_deductions
    tax + national_insurance
  end
end
