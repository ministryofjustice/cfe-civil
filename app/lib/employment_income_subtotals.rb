class EmploymentIncomeSubtotals
  class << self
    def blank
      new(employment_result: nil, employment_details_results: [], self_employment_results: [])
    end
  end

  def initialize(employment_result:, employment_details_results:, self_employment_results:)
    @employment_result = employment_result
    @employment_details_results = employment_details_results
    @self_employment_results = self_employment_results
  end

  def net_employment_income
    gross_employment_income + benefits_in_kind + employment_income_deductions + fixed_employment_allowance
  end

  def disposable_employment_deductions
    fixed_employment_allowance + employment_income_deductions
  end

  def employment_details
    @employment_details_results.flat_map(&:employments)
  end

  def self_employment_details
    @self_employment_results.flat_map(&:employments)
  end

  def gross_employment_income
    employment_results.flat_map(&:employments).sum(&:monthly_gross_income)
  end

  def benefits_in_kind
    employment_results.flat_map(&:employments).sum(&:monthly_benefits_in_kind)
  end

  def tax
    employment_results.flat_map(&:employments).sum(&:monthly_tax)
  end

  def national_insurance
    employment_results.flat_map(&:employments).sum(&:monthly_national_insurance)
  end

  def prisoner_levy
    employment_results.flat_map(&:employments).sum(&:monthly_prisoner_levy)
  end

  def student_debt_repayment
    employment_results.flat_map(&:employments).sum(&:monthly_student_debt_repayment)
  end

  def fixed_employment_allowance
    employment_results.map(&:result).map(&:fixed_employment_allowance).min || 0.0
  end

  def entitles_child_care_allowance?
    return true if self_employment_details.sum(&:monthly_gross_income).positive?

    employments_excluding_self_employments.any?(&:entitles_childcare_allowance?)
  end

  def payment_based_employments
    [@employment_result].compact.flat_map(&:employments)
  end

private

  def employment_income_deductions
    tax + national_insurance + prisoner_levy + student_debt_repayment
  end

  def employments_excluding_self_employments
    (@employment_details_results + [@employment_result]).compact.flat_map(&:employments)
  end

  def employment_results
    [@employment_result].compact + @employment_details_results + @self_employment_results
  end
end
