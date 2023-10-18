class CapitalCollatorAndAssessor
  class << self
    def call(submission_date:, level_of_help:, capitals_data:, date_of_birth:, total_disposable_income:)
      applicant_subtotals = collate_applicant_capital(
        submission_date:,
        level_of_help:,
        pensioner_capital_disregard: Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth:),
        capitals_data:,
      )

      Capital::Subtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: [], properties: []),
        level_of_help:,
        submission_date:,
      )
    end

    def passported(submission_date:, level_of_help:, capitals_data:, date_of_birth:)
      applicant_subtotals = collate_applicant_capital(
        submission_date:,
        level_of_help:,
        pensioner_capital_disregard: Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth:),
        capitals_data:,
      )

      Capital::Subtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: [], properties: []),
        level_of_help:,
        submission_date:,
      )
    end

    def partner(submission_date:, level_of_help:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:,
                total_disposable_income:)
      applicant_value = Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth:)
      partner_value = Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth: partner_date_of_birth)

      applicant_subtotals = collate_applicant_capital(submission_date:,
                                                      level_of_help:,
                                                      pensioner_capital_disregard: [applicant_value, partner_value].max,
                                                      capitals_data:)
      partner_subtotals = collate_partner_capital(submission_date:,
                                                  level_of_help:,
                                                  pensioner_capital_disregard: applicant_subtotals.pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied,
                                                  capitals_data: partner_capitals_data)
      Capital::Subtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: partner_subtotals,
        level_of_help:,
        submission_date:,
      )
    end

    def partner_passported(submission_date:, level_of_help:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:)
      applicant_value = Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth:)
      partner_value = Calculators::PensionerCapitalDisregardCalculator.passported_value(submission_date:, date_of_birth: partner_date_of_birth)

      applicant_subtotals = collate_applicant_capital(submission_date:,
                                                      level_of_help:,
                                                      pensioner_capital_disregard: [applicant_value, partner_value].max,
                                                      capitals_data:)
      partner_subtotals = collate_partner_capital(submission_date:,
                                                  level_of_help:,
                                                  pensioner_capital_disregard: applicant_subtotals.pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied,
                                                  capitals_data: partner_capitals_data)
      Capital::Subtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: partner_subtotals,
        level_of_help:,
        submission_date:,
      )
    end

  private

    def collate_applicant_capital(submission_date:, level_of_help:, pensioner_capital_disregard:, capitals_data:)
      Collators::CapitalCollator.call(
        capitals_data:,
        submission_date:,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(submission_date),
        pensioner_capital_disregard:,
        level_of_help:,
      )
    end

    def collate_partner_capital(submission_date:, level_of_help:, pensioner_capital_disregard:, capitals_data:)
      Collators::CapitalCollator.call(
        capitals_data:,
        submission_date:,
        pensioner_capital_disregard:,
        # partner assets cannot be considered as a subject matter of dispute
        maximum_subject_matter_of_dispute_disregard: 0,
        level_of_help:,
      )
    end

    def maximum_subject_matter_of_dispute_disregard(submission_date)
      Threshold.value_for(:subject_matter_of_dispute_disregard, at: submission_date)
    end
  end
end
