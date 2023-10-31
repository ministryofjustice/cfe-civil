module Workflows
  class PassportedWorkflow
    class << self
      def call(capitals_data:, date_of_birth:, submission_date:, level_of_help:)
        capital_subtotals = CapitalCollatorAndAssessor.passported(capitals_data:, submission_date:, level_of_help:,
                                                                  date_of_birth:)
        CalculationOutput.new(capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(submission_date:, level_of_help:))
      end

      def partner(capitals_data:, partner_capitals_data:, date_of_birth:,
                  partner_date_of_birth:,
                  submission_date:, level_of_help:)
        capital_subtotals = CapitalCollatorAndAssessor.partner_passported(capitals_data:, partner_capitals_data:, date_of_birth:,
                                                                          partner_date_of_birth:, submission_date:, level_of_help:)
        CalculationOutput.new(capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(submission_date:, level_of_help:))
      end
    end
  end
end
