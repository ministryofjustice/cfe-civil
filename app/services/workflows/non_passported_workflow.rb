module Workflows
  class NonPassportedWorkflow
    class << self
      def call(assessment)
        gross_income_subtotals = collate_and_assess_gross_income assessment
        return CalculationOutput.new(gross_income_subtotals:) if assessment.gross_income_summary.ineligible?

        disposable_income_subtotals = disposable_income_assessment(assessment, gross_income_subtotals)
        return CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:) if assessment.disposable_income_summary.ineligible?

        capital_subtotals = collate_and_assess_capital assessment
        CalculationOutput.new(capital_subtotals:, gross_income_subtotals:, disposable_income_subtotals:)
      end

    private

      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :actively_working?,
                                   :monthly_benefits_in_kind, :monthly_national_insurance)

      def convert_employment(employment, submission_date)
        Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(employment)
        Calculators::EmploymentMonthlyValueCalculator.call(employment, submission_date)
        EmploymentData.new(monthly_tax: employment.monthly_tax,
                           monthly_gross_income: employment.monthly_gross_income,
                           monthly_national_insurance: employment.monthly_national_insurance,
                           actively_working?: employment.actively_working?,
                           client_id: employment.client_id,
                           monthly_benefits_in_kind: employment.monthly_benefits_in_kind)
      end

      def collate_and_assess_gross_income(assessment)
        employments = assessment.employments.map { convert_employment(_1, assessment.submission_date) }
        applicant_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                               submission_date: assessment.submission_date,
                                                                               employments:,
                                                                               gross_income_summary: assessment.gross_income_summary)
        if assessment.partner.present?
          assessment.partner_employments.each { |employment| Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(employment) }
          partner_employments = assessment.partner_employments.map { convert_employment(_1, assessment.submission_date) }

          partner_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                               submission_date: assessment.submission_date,
                                                                               employments: partner_employments,
                                                                               gross_income_summary: assessment.partner_gross_income_summary)
        else
          partner_gross_income_subtotals = PersonGrossIncomeSubtotals.blank
        end

        GrossIncomeSubtotals.new(
          applicant_gross_income_subtotals:,
          partner_gross_income_subtotals:,
        ).tap do |gross_income_subtotals|
          Assessors::GrossIncomeAssessor.call(
            eligibilities: assessment.gross_income_summary.eligibilities,
            total_gross_income: gross_income_subtotals.combined_monthly_gross_income,
          )
        end
      end

      def disposable_income_assessment(assessment, gross_income_subtotals)
        result = if assessment.partner.present?
                   partner_disposable_income_assessment(assessment, gross_income_subtotals)
                 else
                   single_disposable_income_assessment(assessment, gross_income_subtotals)
                 end
        result.tap do
          Assessors::DisposableIncomeAssessor.call(disposable_income_summary: assessment.disposable_income_summary,
                                                   total_disposable_income: assessment.disposable_income_summary.combined_total_disposable_income)
        end
      end

      # TODO: make the Collators::DisposableIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
      def partner_disposable_income_assessment(assessment, gross_income_subtotals)
        applicant = PersonWrapper.new person: assessment.applicant, is_single: false,
                                      submission_date: assessment.submission_date,
                                      dependants: assessment.client_dependants,
                                      gross_income_summary: assessment.gross_income_summary
        partner = PersonWrapper.new person: assessment.partner, is_single: false,
                                    submission_date: assessment.submission_date,
                                    dependants: assessment.partner_dependants,
                                    gross_income_summary: assessment.partner_gross_income_summary
        eligible_for_childcare = calculate_childcare_eligibility(assessment, applicant, partner)
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.gross_income_summary.freeze,
                                                      disposable_income_summary: assessment.disposable_income_summary,
                                                      eligible_for_childcare:,
                                                      allow_negative_net: true)
        partner_outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                              person: partner,
                                                              gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                              disposable_income_summary: assessment.partner_disposable_income_summary,
                                                              eligible_for_childcare:,
                                                              allow_negative_net: true)

        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 partner_allowance: partner_allowance(assessment.submission_date),
                                                 gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                 outgoings:)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.partner_disposable_income_summary,
                                                 partner_allowance: 0,
                                                 gross_income_subtotals: gross_income_subtotals.partner_gross_income_subtotals,
                                                 outgoings: partner_outgoings)

        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 eligible_for_childcare:)
        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.partner_disposable_income_summary,
                                                 eligible_for_childcare:)

        assessment.disposable_income_summary.update!(
          combined_total_disposable_income: assessment.disposable_income_summary.total_disposable_income +
                                              assessment.partner_disposable_income_summary.total_disposable_income,
          combined_total_outgoings_and_allowances: assessment.disposable_income_summary.total_outgoings_and_allowances +
                                                     assessment.partner_disposable_income_summary.total_outgoings_and_allowances,
        )
        DisposableIncomeSubtotals.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(partner_outgoings),
        )
      end

      def single_disposable_income_assessment(assessment, gross_income_subtotals)
        applicant = PersonWrapper.new person: assessment.applicant, is_single: true,
                                      submission_date: assessment.submission_date,
                                      dependants: assessment.client_dependants, gross_income_summary: assessment.gross_income_summary
        eligible_for_childcare = calculate_childcare_eligibility(assessment, applicant)
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.gross_income_summary.freeze,
                                                      disposable_income_summary: assessment.disposable_income_summary,
                                                      eligible_for_childcare:,
                                                      allow_negative_net: false)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 partner_allowance: 0,
                                                 gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                 outgoings:)
        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 eligible_for_childcare:)
        assessment.disposable_income_summary.update!(combined_total_disposable_income: assessment.disposable_income_summary.total_disposable_income,
                                                     combined_total_outgoings_and_allowances: assessment.disposable_income_summary.total_outgoings_and_allowances)
        DisposableIncomeSubtotals.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        )
      end

      def collate_and_assess_capital(assessment)
        CapitalCollatorAndAssessor.call assessment
      end

      def calculate_childcare_eligibility(assessment, applicant, partner = nil)
        Calculators::ChildcareEligibilityCalculator.call(
          applicant:,
          partner:,
          dependants: assessment.client_dependants + assessment.partner_dependants, # Ensure we consider both client and partner dependants
          submission_date: assessment.submission_date,
        )
      end

      def partner_allowance(submission_date)
        Threshold.value_for(:partner_allowance, at: submission_date)
      end
    end
  end
end
