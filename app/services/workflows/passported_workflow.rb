module Workflows
  class PassportedWorkflow
    class << self
      def call(proceeding_types:, capitals_data:, date_of_birth:, receives_asylum_support:, submission_date:, level_of_help:)
        capital_subtotals = CapitalCollatorAndAssessor.passported(proceeding_types:, capitals_data:, submission_date:, level_of_help:,
                                                                  date_of_birth:)
        CalculationOutput.new(receives_qualifying_benefit: true, receives_asylum_support:, proceeding_types:,
                              capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(proceeding_types:, submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(proceeding_types))
      end

      def partner(proceeding_types:, capitals_data:, partner_capitals_data:, date_of_birth:,
                  partner_date_of_birth:, receives_asylum_support:,
                  submission_date:, level_of_help:)
        capital_subtotals = CapitalCollatorAndAssessor.partner_passported(proceeding_types:, capitals_data:, partner_capitals_data:, date_of_birth:,
                                                                          partner_date_of_birth:, submission_date:, level_of_help:)
        CalculationOutput.new(receives_qualifying_benefit: true, receives_asylum_support:, proceeding_types:,
                              capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(proceeding_types:, submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(proceeding_types))
      end
    end
  end
end
