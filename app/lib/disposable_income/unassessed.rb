module DisposableIncome
  class Unassessed < Base
    def initialize(level_of_help:, submission_date:)
      super(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
            applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank)
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def eligibilities(proceeding_types)
      Creators::DisposableIncomeEligibilityCreator.unassessed proceeding_types:,
                                                              level_of_help: @level_of_help,
                                                              submission_date: @submission_date
    end

    def income_contribution(_proceeding_types)
      0
    end
  end
end
