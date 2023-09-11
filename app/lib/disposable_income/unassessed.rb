module DisposableIncome
  class Unassessed < SubtotalsBase
    def initialize(proceeding_types:, level_of_help:, submission_date:)
      super(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
            applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
            combined_total_disposable_income: 0,
            combined_total_outgoings_and_allowances: 0,
            proceeding_types:, level_of_help:, submission_date:)
    end

    def eligibilities
      Creators::DisposableIncomeEligibilityCreator.unassessed proceeding_types: @proceeding_types,
                                                              level_of_help: @level_of_help,
                                                              submission_date: @submission_date
    end

    def income_contribution
      0
    end
  end
end
