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

  def employment_income_deductions
    tax + national_insurance
  end

  def employment_details
    @employment_details_results.map(&:employment)
  end

  def self_employment_details
    @self_employment_results.map(&:employment)
  end

  def gross_employment_income
    employment_results.map(&:employment).sum(&:monthly_gross_income)
  end

  def benefits_in_kind
    employment_results.map(&:employment).sum(&:monthly_benefits_in_kind)
  end

  def tax
    employment_results.map(&:employment).sum(&:monthly_tax)
  end

  def national_insurance
    employment_results.map(&:employment).sum(&:monthly_national_insurance)
  end

  def fixed_employment_allowance
    employment_results.map(&:result).map(&:fixed_employment_allowance).min || 0.0
  end

  def entitles_child_care_allowance?
    return true if @self_employment_results.any? && self_employment_details.sum(&:monthly_gross_income).positive?

    employments_excluding_self_employments.any?(&:entitles_employment_allowance?) && employments_excluding_self_employments.any?(&:has_positive_gross_income?)
  end

private

  def employments_excluding_self_employments
    (@employment_details_results + [@employment_result]).compact.map(&:employment)
  end

  def employment_results
    [@employment_result].compact + @employment_details_results + @self_employment_results
  end
end
