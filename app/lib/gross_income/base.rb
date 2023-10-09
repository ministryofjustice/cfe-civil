module GrossIncome
  class Base
    attr_reader :applicant_gross_income_subtotals, :partner_gross_income_subtotals, :self_employments, :partner_self_employments

    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                   self_employments:, partner_self_employments:,
                   dependants:, proceeding_types:)
      @applicant_gross_income_subtotals = applicant_gross_income_subtotals
      @partner_gross_income_subtotals = partner_gross_income_subtotals
      @self_employments = self_employments
      @partner_self_employments = partner_self_employments
      @dependants = dependants
      @proceeding_types = proceeding_types
    end

    def combined_monthly_gross_income
      @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
    end

    def summarized_assessment_result
      Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
    end

    def eligible?
      summarized_assessment_result.in? %i[eligible partially_eligible]
    end

    def ineligible?
      !eligible?
    end
  end
end
