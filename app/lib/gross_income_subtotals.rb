class GrossIncomeSubtotals
  class << self
    def blank
      new applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
          partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
          self_employments: [],
          partner_self_employments: []
    end
  end

  attr_reader :applicant_gross_income_subtotals, :partner_gross_income_subtotals, :self_employments, :partner_self_employments

  def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:, self_employments:, partner_self_employments:)
    @applicant_gross_income_subtotals = applicant_gross_income_subtotals
    @partner_gross_income_subtotals = partner_gross_income_subtotals
    @self_employments = self_employments
    @partner_self_employments = partner_self_employments
  end

  def combined_monthly_gross_income
    @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
  end
end
