module Workflows
  class PassportedWorkflow
    class << self
      def without_partner(capitals_data:, date_of_birth:, submission_date:, level_of_help:)
        applicant_subtotals = Collators::CapitalCollator.collate_applicant_capital(
          submission_date:,
          level_of_help:,
          pensioner_capital_disregard: Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth:),
          capitals_data:,
        )

        capital_subtotals = Capital::CapitalResult.new(applicant_capital_subtotals: applicant_subtotals, level_of_help:, submission_date:)
        CalculationOutput.new(submission_date:, level_of_help:, capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(submission_date:, level_of_help:))
      end

      def with_partner(capitals_data:, partner_capitals_data:, date_of_birth:,
                       partner_date_of_birth:,
                       submission_date:, level_of_help:)
        capital_subtotals = partner_passported(capitals_data:, partner_capitals_data:, date_of_birth:,
                                               partner_date_of_birth:, submission_date:, level_of_help:)
        CalculationOutput.new(level_of_help:, submission_date:, capital_subtotals:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(submission_date:, level_of_help:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(submission_date:, level_of_help:))
      end

    private

      def partner_passported(submission_date:, level_of_help:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:)
        applicant_value = Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth:)
        partner_value = Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth: partner_date_of_birth)

        applicant_subtotals = Collators::CapitalCollator.collate_applicant_capital(submission_date:,
                                                                                   level_of_help:,
                                                                                   pensioner_capital_disregard: [applicant_value, partner_value].max,
                                                                                   capitals_data:)
        partner_subtotals = Collators::CapitalCollator.collate_partner_capital(submission_date:,
                                                                               level_of_help:,
                                                                               pensioner_capital_disregard: applicant_subtotals.pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied,
                                                                               capitals_data: partner_capitals_data)
        Capital::CapitalResultWithPartner.new(
          applicant_capital_subtotals: applicant_subtotals,
          partner_capital_subtotals: partner_subtotals,
          level_of_help:,
          submission_date:,
        )
      end
    end
  end
end
