module DisposableIncome
  class Unassessed < Base
    def initialize(proceeding_types:, level_of_help:, submission_date:)
      super(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
            applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
            proceeding_types:, level_of_help:, submission_date:)
    end

    def eligibilities
      Creators::DisposableIncomeEligibilityCreator.unassessed proceeding_types: @proceeding_types,
                                                              level_of_help: @level_of_help,
                                                              submission_date: @submission_date
    end

    def combined_total_disposable_income
      0
    end

    def income_contribution
      0
    end
  end
end
