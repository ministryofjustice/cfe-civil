module GrossIncome
  class Unassessed < Base
    def initialize
      super applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
            partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank
    end

    def combined_monthly_gross_income
      0
    end

    def eligibilities(proceeding_types)
      proceeding_types.map do |proceeding_type|
        Eligibility::GrossIncome.new(
          proceeding_type:,
          upper_threshold: proceeding_type.gross_income_upper_threshold,
          assessment_result: "pending",
        )
      end
    end
  end
end
