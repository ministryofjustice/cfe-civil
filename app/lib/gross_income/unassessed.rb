module GrossIncome
  class Unassessed < Base
    def initialize(level_of_help:, submission_date:)
      super applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
            partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def combined_monthly_gross_income
      0
    end

    def eligibilities(proceeding_types)
      proceeding_types.map do |proceeding_type|
        Eligibility::GrossIncome.new(
          proceeding_type:,
          upper_threshold: proceeding_type.gross_income_upper_threshold,
          lower_threshold: Creators::GrossIncomeEligibilityCreator.lower_threshold(level_of_help: @level_of_help, submission_date: @submission_date),
          assessment_result: "not_calculated",
        )
      end
    end
  end
end
