module Workflows
  class NonPassportedWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        applicant_self_employments = convert_employment_details(applicant.self_employments)
        applicant_employment_details = convert_employment_details(applicant.employment_details)
        applicant_gross_income = collate_gross_income(assessment:,
                                                      employments: assessment.employments,
                                                      gross_income_summary: assessment.applicant_gross_income_summary,
                                                      self_employments: applicant_self_employments,
                                                      employment_details: applicant_employment_details)

        gross_income_subtotals = if partner.present?
                                   partner_self_employments = convert_employment_details(partner.self_employments)
                                   partner_employment_details = convert_employment_details(partner.employment_details)
                                   partner_gross_income = collate_gross_income(assessment:,
                                                                               employments: assessment.partner_employments,
                                                                               gross_income_summary: assessment.partner_gross_income_summary,
                                                                               self_employments: partner_self_employments,
                                                                               employment_details: partner_employment_details)

                                   collate_and_assess_gross_income(assessment:,
                                                                   applicant_gross_income_subtotals: applicant_gross_income,
                                                                   partner_gross_income_subtotals: partner_gross_income,
                                                                   self_employments: applicant_employment_details,
                                                                   partner_self_employments: partner_employment_details)
                                 else
                                   collate_and_assess_gross_income(assessment:,
                                                                   applicant_gross_income_subtotals: applicant_gross_income,
                                                                   partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
                                                                   self_employments: applicant_employment_details,
                                                                   partner_self_employments: [])
                                 end
        unassessed_capital = CapitalSubtotals.unassessed(applicant:, partner:,
                                                         applicant_properties: assessment.applicant_capital_summary.properties,
                                                         partner_properties: assessment.partner_capital_summary&.properties || [])
        return CalculationOutput.new(gross_income_subtotals:, capital_subtotals: unassessed_capital) if assessment.applicant_gross_income_summary.ineligible?

        disposable_income_subtotals = if partner.present?
                                        partner_disposable_income_assessment(assessment:,
                                                                             gross_income_subtotals:,
                                                                             applicant_person_data: applicant,
                                                                             partner_person_data: partner)
                                      else
                                        single_disposable_income_assessment(assessment:, gross_income_subtotals:,
                                                                            applicant_person_data: applicant)
                                      end
        Assessors::DisposableIncomeAssessor.call(
          disposable_income_summary: assessment.applicant_disposable_income_summary,
          total_disposable_income: assessment.applicant_disposable_income_summary.combined_total_disposable_income,
        )

        return CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals: unassessed_capital) if assessment.applicant_disposable_income_summary.ineligible?

        capital_subtotals = if partner.present?
                              CapitalCollatorAndAssessor.partner assessment:,
                                                                 vehicles: applicant.vehicles,
                                                                 partner_vehicles: partner.vehicles,
                                                                 date_of_birth: applicant.details.date_of_birth,
                                                                 partner_date_of_birth: partner.details.date_of_birth,
                                                                 receives_qualifying_benefit: applicant.details.receives_qualifying_benefit
                            else
                              CapitalCollatorAndAssessor.call assessment:, vehicles: applicant.vehicles,
                                                              date_of_birth: applicant.details.date_of_birth,
                                                              receives_qualifying_benefit: applicant.details.receives_qualifying_benefit
                            end
        CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:)
      end

    private

      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :actively_working?,
                                   :monthly_benefits_in_kind, :monthly_national_insurance)

      # local define for employment and monthly_values
      EmploymentResult = Data.define(:employment, :values)

      def convert_employment_payments(assessment, employments, submission_date)
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

      def convert_employment_details(employment_details)
        employment_details.map do |detail|
          monthly_gross_income = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.gross)
          monthly_national_insurance = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.national_insurance)
          monthly_tax = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.tax)
          monthly_benefits_in_kind = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.benefits_in_kind)

          EmploymentData.new(monthly_tax:,
                             monthly_gross_income:,
                             monthly_national_insurance:,
                             actively_working?: detail.income.actively_working?,
                             client_id: detail.client_reference,
                             monthly_benefits_in_kind:)
        end
      end

      def collate_gross_income(assessment:, employments:, gross_income_summary:, self_employments:, employment_details:)
        converted_employments = convert_employment_payments(assessment, employments, assessment.submission_date)
        Collators::GrossIncomeCollator.call(assessment:,
                                            submission_date: assessment.submission_date,
                                            self_employments:,
                                            employment_details:,
                                            employments: converted_employments,
                                            gross_income_summary:)
      end

      def collate_and_assess_gross_income(assessment:, self_employments:, partner_self_employments:,
                                          applicant_gross_income_subtotals:, partner_gross_income_subtotals:)

        GrossIncomeSubtotals.new(
          applicant_gross_income_subtotals:,
          partner_gross_income_subtotals:,
          self_employments:,
          partner_self_employments:,
        ).tap do |gross_income_subtotals|
          Assessors::GrossIncomeAssessor.call(
            eligibilities: assessment.applicant_gross_income_summary.eligibilities,
            total_gross_income: gross_income_subtotals.combined_monthly_gross_income,
          )
        end
      end

      # TODO: make the Collators::DisposableIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
      def partner_disposable_income_assessment(assessment:, gross_income_subtotals:, applicant_person_data:, partner_person_data:)
        applicant = PersonWrapper.new is_single: false,
                                      submission_date: assessment.submission_date,
                                      applicant_person_data:,
                                      employments: assessment.employments,
                                      gross_income_summary: assessment.applicant_gross_income_summary
        partner = PersonWrapper.new is_single: false,
                                    submission_date: assessment.submission_date,
                                    gross_income_summary: assessment.partner_gross_income_summary,
                                    applicant_person_data: partner_person_data,
                                    employments: assessment.partner_employments
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
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings, partner_allowance(assessment.submission_date)),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(partner_outgoings, 0),
        )
      end

      def single_disposable_income_assessment(assessment:, gross_income_subtotals:, applicant_person_data:)
        applicant = PersonWrapper.new applicant_person_data:,
                                      is_single: true,
                                      submission_date: assessment.submission_date,
                                      gross_income_summary: assessment.applicant_gross_income_summary,
                                      employments: assessment.employments
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
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(outgoings, 0),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        )
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
