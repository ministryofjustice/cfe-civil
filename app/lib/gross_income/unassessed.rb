module GrossIncome
  class Unassessed < Base
    def initialize(proceeding_types)
      super applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
            partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
            self_employments: [],
            partner_self_employments: [],
            dependants: [],
            proceeding_types:
    end

    def eligibilities
      @proceeding_types.map do |proceeding_type|
        Eligibility::GrossIncome.new(
          proceeding_type:,
          upper_threshold: proceeding_type.gross_income_upper_threshold,
          assessment_result: "pending",
        )
      end
    end
  end
end
