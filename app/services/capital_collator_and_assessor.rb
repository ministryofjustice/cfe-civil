class CapitalCollatorAndAssessor
  class << self
    def call(assessment:, vehicles:, date_of_birth:, receives_qualifying_benefit:)
      pensioner_capital_disregard = pensioner_capital_disregard(submission_date: assessment.submission_date, date_of_birth:, receives_qualifying_benefit:,
                                                                total_disposable_income: assessment.applicant_disposable_income_summary.total_disposable_income)
      applicant_subtotals = collate_applicant_capital(assessment, pensioner_capital_disregard:, vehicles:)
      combined_assessed_capital = applicant_subtotals.assessed_capital
      capital_contribution = Assessors::CapitalAssessor.call(assessment.applicant_capital_summary, combined_assessed_capital)
      CapitalSubtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: []),
        capital_contribution:,
        combined_assessed_capital:,
      )
    end

    def partner(assessment:, vehicles:, partner_vehicles:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:)
      total_disposable_income = assessment.applicant_disposable_income_summary.total_disposable_income +
        assessment.partner_disposable_income_summary.total_disposable_income

      pensioner_capital_disregard = partner_pensioner_capital_disregard(submission_date: assessment.submission_date, date_of_birth:, partner_date_of_birth:,
                                                                        receives_qualifying_benefit:, total_disposable_income:)
      applicant_subtotals = collate_applicant_capital(assessment, pensioner_capital_disregard:, vehicles:)
      partner_subtotals = collate_partner_capital(assessment,
                                                  pensioner_capital_disregard: pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied,
                                                  vehicles: partner_vehicles)
      combined_assessed_capital = applicant_subtotals.assessed_capital + partner_subtotals.assessed_capital
      capital_contribution = Assessors::CapitalAssessor.call(assessment.applicant_capital_summary, combined_assessed_capital)
      CapitalSubtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: partner_subtotals,
        capital_contribution:,
        combined_assessed_capital:,
      )
    end

  private

    def collate_applicant_capital(assessment, pensioner_capital_disregard:, vehicles:)
      Collators::CapitalCollator.call(
        vehicles:,
        submission_date: assessment.submission_date,
        capital_summary: assessment.applicant_capital_summary,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(assessment.submission_date),
        pensioner_capital_disregard:,
        level_of_help: assessment.level_of_help,
      )
    end

    def collate_partner_capital(assessment, pensioner_capital_disregard:, vehicles:)
      Collators::CapitalCollator.call(
        vehicles:,
        submission_date: assessment.submission_date,
        capital_summary: assessment.partner_capital_summary,
        pensioner_capital_disregard:,
        # partner assets cannot be considered as a subject matter of dispute
        maximum_subject_matter_of_dispute_disregard: 0,
        level_of_help: assessment.level_of_help,
      )
    end

    def pensioner_capital_disregard(submission_date:, date_of_birth:, receives_qualifying_benefit:, total_disposable_income:)
      Calculators::PensionerCapitalDisregardCalculator.new(
        submission_date:,
        receives_qualifying_benefit:,
        total_disposable_income:,
        date_of_birth:,
      ).value
    end

    def partner_pensioner_capital_disregard(submission_date:, date_of_birth:, partner_date_of_birth:, receives_qualifying_benefit:, total_disposable_income:)
      applicant_value = Calculators::PensionerCapitalDisregardCalculator.new(
        submission_date:,
        receives_qualifying_benefit:,
        total_disposable_income:,
        date_of_birth:,
      )
      partner_value = Calculators::PensionerCapitalDisregardCalculator.new(
        submission_date:,
        receives_qualifying_benefit:,
        total_disposable_income:,
        date_of_birth: partner_date_of_birth,
      )
      [applicant_value, partner_value].map(&:value).max
    end

    def maximum_subject_matter_of_dispute_disregard(submission_date)
      Threshold.value_for(:subject_matter_of_dispute_disregard, at: submission_date)
    end
  end
end
