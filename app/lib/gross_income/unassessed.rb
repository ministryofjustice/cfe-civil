module GrossIncome
  class Unassessed < Base
    def initialize(level_of_help:, submission_date:)
      super applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
            partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def assessed?
      false
    end

    def combined_monthly_gross_income
      0
    end

    # def dependants
    #   []
    # end
  end
end
