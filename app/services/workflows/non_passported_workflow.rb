module Workflows
  class NonPassportedWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        gross_income_subtotals = collate_and_assess_gross_income(assessment:,
                                                                 self_employments: applicant.self_employments,
                                                                 partner_self_employments: partner&.self_employments || [])
        return CalculationOutput.new(gross_income_subtotals:) if assessment.applicant_gross_income_summary.ineligible?

        disposable_income_subtotals = disposable_income_assessment(assessment:, gross_income_subtotals:,
                                                                   dependants: applicant.dependants,
                                                                   partner_dependants: partner&.dependants || [])
        return CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:) if assessment.applicant_disposable_income_summary.ineligible?

        capital_subtotals = collate_and_assess_capital(assessment:, vehicles: applicant.vehicles, partner_vehicles: partner&.vehicles || [])
        CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:)
      end

    private

      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :actively_working?,
                                   :monthly_benefits_in_kind, :monthly_national_insurance)

      # local define for employment and monthly_values
      EmploymentResult = Data.define(:employment, :values)

      def convert_employments(assessment, employments, submission_date)
        remarks = assessment.remarks

        answers = employments.map do
          monthly_equivalent_payments = Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(_1.employment_payments)
          remarks_and_values = Calculators::EmploymentMonthlyValueCalculator.call(_1, submission_date, monthly_equivalent_payments)
          remarks_and_values.remarks.each do |remark|
            remarks.add(remark.type, remark.issue, remark.ids)
          end
          EmploymentResult.new employment: _1, values: remarks_and_values.values
        end
        assessment.update!(remarks:)

        answers.map do
          EmploymentData.new(monthly_tax: _1.values.fetch(:monthly_tax),
                             monthly_gross_income: _1.values.fetch(:monthly_gross_income),
                             monthly_national_insurance: _1.values.fetch(:monthly_national_insurance),
                             actively_working?: _1.employment.actively_working?,
                             client_id: _1.employment.client_id,
                             monthly_benefits_in_kind: _1.values.fetch(:monthly_benefits_in_kind))
        end
      end

      def aggregate_self_employments(self_employments)
        if self_employments.any?
          # need to aggregregate employments here to avoid the issue with multiple employments producing zero income
          aggregated_employments = convert_self_employments(self_employments).reduce do |prev, current|
            EmploymentData.new(monthly_tax: prev.monthly_tax + current.monthly_tax,
                               monthly_gross_income: prev.monthly_gross_income + current.monthly_gross_income,
                               monthly_national_insurance: prev.monthly_national_insurance + current.monthly_national_insurance,
                               actively_working?: prev.actively_working? || current.actively_working?,
                               client_id: "dummy_client_id",
                               monthly_benefits_in_kind: prev.monthly_benefits_in_kind + current.monthly_benefits_in_kind)
          end
          [aggregated_employments]
        else
          []
        end
      end

      def convert_self_employments(self_employments)
        self_employments.map do |self_employment|
          monthly_gross_income = Utilities::MonthlyAmountConverter.call(self_employment.income.frequency, self_employment.income.gross)
          monthly_national_insurance = Utilities::MonthlyAmountConverter.call(self_employment.income.frequency, self_employment.income.national_insurance)
          monthly_tax = Utilities::MonthlyAmountConverter.call(self_employment.income.frequency, self_employment.income.tax)
          monthly_benefits_in_kind = Utilities::MonthlyAmountConverter.call(self_employment.income.frequency, self_employment.income.benefits_in_kind)

          EmploymentData.new(monthly_tax:,
                             monthly_gross_income:,
                             monthly_national_insurance:,
                             actively_working?: self_employment.income.actively_working?,
                             client_id: self_employment.client_reference,
                             monthly_benefits_in_kind:)
        end
      end

      def collate_and_assess_gross_income(assessment:, self_employments:, partner_self_employments:)
        converted_employments = convert_employments(assessment, assessment.employments, assessment.submission_date)
        applicant_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                               submission_date: assessment.submission_date,
                                                                               employments: converted_employments + aggregate_self_employments(self_employments),
                                                                               gross_income_summary: assessment.applicant_gross_income_summary)
        partner_gross_income_subtotals = if assessment.partner.present?
                                           partner_employments = convert_employments(assessment, assessment.partner_employments, assessment.submission_date)

                                           Collators::GrossIncomeCollator.call(
                                             assessment:,
                                             submission_date: assessment.submission_date,
                                             employments: partner_employments + aggregate_self_employments(partner_self_employments),
                                             gross_income_summary: assessment.partner_gross_income_summary,
                                           )
                                         else
                                           PersonGrossIncomeSubtotals.blank
                                         end

        GrossIncomeSubtotals.new(
          applicant_gross_income_subtotals:,
          partner_gross_income_subtotals:,
          self_employments: convert_self_employments(self_employments),
          partner_self_employments: convert_self_employments(partner_self_employments),
        ).tap do |gross_income_subtotals|
          Assessors::GrossIncomeAssessor.call(
            eligibilities: assessment.applicant_gross_income_summary.eligibilities,
            total_gross_income: gross_income_subtotals.combined_monthly_gross_income,
          )
        end
      end

      def disposable_income_assessment(assessment:, gross_income_subtotals:, dependants:, partner_dependants:)
        result = if assessment.partner.present?
                   partner_disposable_income_assessment(assessment:, gross_income_subtotals:, dependants:, partner_dependants:)
                 else
                   single_disposable_income_assessment(assessment:, gross_income_subtotals:, dependants:)
                 end
        result.tap do
          Assessors::DisposableIncomeAssessor.call(disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                   total_disposable_income: assessment.applicant_disposable_income_summary.combined_total_disposable_income)
        end
      end

      # TODO: make the Collators::DisposableIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
      def partner_disposable_income_assessment(assessment:, gross_income_subtotals:, dependants:, partner_dependants:)
        applicant = PersonWrapper.new person: assessment.applicant, is_single: false,
                                      submission_date: assessment.submission_date,
                                      dependants:, gross_income_summary: assessment.applicant_gross_income_summary
        partner = PersonWrapper.new person: assessment.partner, is_single: false,
                                    submission_date: assessment.submission_date,
                                    dependants: partner_dependants, gross_income_summary: assessment.partner_gross_income_summary
        eligible_for_childcare = calculate_partner_childcare_eligibility(assessment, applicant, partner)
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                      disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                      eligible_for_childcare:,
                                                      allow_negative_net: true)
        partner_outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                              person: partner,
                                                              gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                              disposable_income_summary: assessment.partner_disposable_income_summary,
                                                              eligible_for_childcare:,
                                                              allow_negative_net: true)

        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                 partner_allowance: partner_allowance(assessment.submission_date),
                                                 gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                 outgoings:)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.partner_disposable_income_summary,
                                                 partner_allowance: 0,
                                                 gross_income_subtotals: gross_income_subtotals.partner_gross_income_subtotals,
                                                 outgoings: partner_outgoings)

        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                 eligible_for_childcare:)
        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.partner_disposable_income_summary,
                                                 eligible_for_childcare:)

        assessment.applicant_disposable_income_summary.update!(
          combined_total_disposable_income: assessment.applicant_disposable_income_summary.total_disposable_income +
                                              assessment.partner_disposable_income_summary.total_disposable_income,
          combined_total_outgoings_and_allowances: assessment.applicant_disposable_income_summary.total_outgoings_and_allowances +
                                                     assessment.partner_disposable_income_summary.total_outgoings_and_allowances,
        )
        DisposableIncomeSubtotals.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(partner_outgoings),
        )
      end

      def single_disposable_income_assessment(assessment:, gross_income_subtotals:, dependants:)
        applicant = PersonWrapper.new person: assessment.applicant, is_single: true,
                                      submission_date: assessment.submission_date,
                                      dependants:, gross_income_summary: assessment.applicant_gross_income_summary
        eligible_for_childcare = calculate_childcare_eligibility(assessment, applicant)
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                      disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                      eligible_for_childcare:,
                                                      allow_negative_net: false)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                 partner_allowance: 0,
                                                 gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                 outgoings:)
        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                 eligible_for_childcare:)
        assessment.applicant_disposable_income_summary.update!(combined_total_disposable_income: assessment.applicant_disposable_income_summary.total_disposable_income,
                                                               combined_total_outgoings_and_allowances: assessment.applicant_disposable_income_summary.total_outgoings_and_allowances)
        DisposableIncomeSubtotals.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        )
      end

      def collate_and_assess_capital(assessment:, vehicles:, partner_vehicles:)
        CapitalCollatorAndAssessor.call assessment:, vehicles:, partner_vehicles:
      end

      def calculate_childcare_eligibility(assessment, applicant)
        Calculators::ChildcareEligibilityCalculator.call(
          applicants: [applicant],
          dependants: applicant.dependants, # Ensure we consider both client and partner dependants
          submission_date: assessment.submission_date,
        )
      end

      def calculate_partner_childcare_eligibility(assessment, applicant, partner)
        Calculators::ChildcareEligibilityCalculator.call(
          applicants: [applicant, partner],
          dependants: applicant.dependants + partner.dependants, # Ensure we consider both client and partner dependants
          submission_date: assessment.submission_date,
        )
      end

      def partner_allowance(submission_date)
        Threshold.value_for(:partner_allowance, at: submission_date)
      end
    end
  end
end
