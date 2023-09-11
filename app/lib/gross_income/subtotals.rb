module GrossIncome
  class Subtotals < SubtotalsBase
    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                   self_employments:, partner_self_employments:,
                   dependants:, proceeding_types:, submission_date:)
      super(applicant_gross_income_subtotals:, partner_gross_income_subtotals:, self_employments:, partner_self_employments:, dependants:, proceeding_types:)
      @submission_date = submission_date
    end

    def eligibilities
      Creators::GrossIncomeEligibilityCreator.call dependants: @dependants,
                                                   proceeding_types: @proceeding_types,
                                                   submission_date: @submission_date,
                                                   total_gross_income: combined_monthly_gross_income
    end
  end
end
