module Workflows
  class NonPassportedWorkflow
    class << self
      DisposableResult = Data.define(:applicant_disposable_income_subtotals,
                                     :partner_disposable_income_subtotals) do
        def combined_total_disposable_income
          applicant_disposable_income_subtotals.total_disposable_income +
            partner_disposable_income_subtotals.total_disposable_income
        end

        def combined_total_outgoings_and_allowances
          applicant_disposable_income_subtotals.total_outgoings_and_allowances +
            partner_disposable_income_subtotals.total_outgoings_and_allowances
        end
      end

      def call(assessment:, applicant:, partner:)
        applicant_self_employments = convert_employment_details(applicant.self_employments)
        applicant_employment_details = convert_employment_details(applicant.employment_details)
        applicant_gross_income = collate_gross_income(assessment:,
                                                      employments: applicant.employments,
                                                      gross_income_summary: assessment.applicant_gross_income_summary,
                                                      self_employments: applicant_self_employments,
                                                      employment_details: applicant_employment_details)

        gross_income_subtotals = if partner.present?
                                   partner_self_employments = convert_employment_details(partner.self_employments)
                                   partner_employment_details = convert_employment_details(partner.employment_details)
                                   partner_gross_income = collate_gross_income(assessment:,
                                                                               employments: partner.employments,
                                                                               gross_income_summary: assessment.partner_gross_income_summary,
                                                                               self_employments: partner_self_employments,
                                                                               employment_details: partner_employment_details)

                                   collate_and_assess_gross_income(applicant_gross_income_subtotals: applicant_gross_income,
                                                                   partner_gross_income_subtotals: partner_gross_income,
                                                                   self_employments: applicant_employment_details,
                                                                   partner_self_employments: partner_employment_details,
                                                                   proceeding_types: assessment.proceeding_types,
                                                                   submission_date: assessment.submission_date,
                                                                   dependants: applicant.dependants + (partner.dependants || []))
                                 else
                                   collate_and_assess_gross_income(applicant_gross_income_subtotals: applicant_gross_income,
                                                                   partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
                                                                   self_employments: applicant_employment_details,
                                                                   partner_self_employments: [],
                                                                   proceeding_types: assessment.proceeding_types,
                                                                   submission_date: assessment.submission_date,
                                                                   dependants: applicant.dependants)
                                 end
        unassessed_capital = Capital::Unassessed.new(applicant_capitals: applicant.capitals_data,
                                                     partner_capitals: partner&.capitals_data,
                                                     proceeding_types: assessment.proceeding_types,
                                                     submission_date: assessment.submission_date,
                                                     level_of_help: assessment.level_of_help)
        if gross_income_subtotals.ineligible?
          return CalculationOutput.new(gross_income_subtotals:,
                                       assessment:,
                                       receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                       receives_asylum_support: applicant.details.receives_asylum_support,
                                       disposable_income_subtotals: DisposableIncome::Unassessed.new(proceeding_types: assessment.proceeding_types,
                                                                                                     level_of_help: assessment.level_of_help,
                                                                                                     submission_date: assessment.submission_date),
                                       capital_subtotals: unassessed_capital)
        end

        disposable_result = if partner.present?
                              partner_disposable_income_assessment(assessment:,
                                                                   gross_income_subtotals:,
                                                                   applicant_person_data: applicant,
                                                                   partner_person_data: partner)
                            else
                              single_disposable_income_assessment(assessment:, gross_income_subtotals:,
                                                                  applicant_person_data: applicant)
                            end
        # income_contribution = Summarizers::DisposableIncomeSummarizer.call(
        #   disposable_income_summary: assessment.applicant_disposable_income_summary,
        #   total_disposable_income: disposable_result.combined_total_disposable_income,
        #   submission_date: assessment.submission_date,
        # )
        disposable_income_subtotals = DisposableIncome::Subtotals.new(
          applicant_disposable_income_subtotals: disposable_result.applicant_disposable_income_subtotals,
          partner_disposable_income_subtotals: disposable_result.partner_disposable_income_subtotals,
          # income_contribution:,
          combined_total_disposable_income: disposable_result.combined_total_disposable_income,
          combined_total_outgoings_and_allowances: disposable_result.combined_total_outgoings_and_allowances,
          proceeding_types: assessment.proceeding_types,
          level_of_help: assessment.level_of_help,
          submission_date: assessment.submission_date,
        )

        if disposable_income_subtotals.ineligible?
          return CalculationOutput.new(gross_income_subtotals:,
                                       disposable_income_subtotals:,
                                       capital_subtotals: unassessed_capital,
                                       assessment:,
                                       receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                       receives_asylum_support: applicant.details.receives_asylum_support)
        end

        capital_subtotals = if partner.present?
                              CapitalCollatorAndAssessor.partner assessment:,
                                                                 capitals_data: applicant.capitals_data,
                                                                 partner_capitals_data: partner.capitals_data,
                                                                 date_of_birth: applicant.details.date_of_birth,
                                                                 partner_date_of_birth: partner.details.date_of_birth,
                                                                 receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                                 total_disposable_income: disposable_income_subtotals.combined_total_disposable_income
                            else
                              CapitalCollatorAndAssessor.call assessment:, capitals_data: applicant.capitals_data,
                                                              date_of_birth: applicant.details.date_of_birth,
                                                              receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                              total_disposable_income: disposable_income_subtotals.combined_total_disposable_income
                            end
        CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:,
                              assessment:, receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                              receives_asylum_support: applicant.details.receives_asylum_support)
      end

    private

      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :entitles_employment_allowance?,
                                   :entitles_childcare_allowance?,
                                   :monthly_benefits_in_kind,
                                   :monthly_national_insurance,
                                   :employment_name,
                                   :employment_payments)

      # local define for employment and monthly_values
      EmploymentResult = Data.define(:employment, :values, :payments)

      def convert_employment_payments(assessment, employments, submission_date)
        remarks = assessment.remarks

        answers = employments.map do
          monthly_equivalent_payments = Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(_1.employment_payments)
          remarks_and_values = Calculators::EmploymentMonthlyValueCalculator.call(_1, submission_date, monthly_equivalent_payments)
          remarks_and_values.remarks.each do |remark|
            remarks.add(remark.type, remark.issue, remark.ids)
          end
          EmploymentResult.new employment: _1, values: remarks_and_values.values, payments: remarks_and_values.payments
        end
        assessment.update!(remarks:)

        answers.map do
          EmploymentData.new(monthly_tax: _1.values.fetch(:monthly_tax),
                             monthly_gross_income: _1.values.fetch(:monthly_gross_income),
                             monthly_national_insurance: _1.values.fetch(:monthly_national_insurance),
                             entitles_employment_allowance?: _1.employment.entitles_employment_allowance?,
                             entitles_childcare_allowance?: _1.employment.entitles_childcare_allowance?,
                             client_id: _1.employment.client_id,
                             monthly_benefits_in_kind: _1.values.fetch(:monthly_benefits_in_kind),
                             employment_name: _1.employment.name,
                             employment_payments: _1.payments)
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
                             entitles_employment_allowance?: detail.income.entitles_employment_allowance?,
                             entitles_childcare_allowance?: detail.income.entitles_childcare_allowance?,
                             client_id: detail.client_reference,
                             monthly_benefits_in_kind:,
                             employment_name: nil,
                             employment_payments: [])
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

      def collate_and_assess_gross_income(self_employments:, partner_self_employments:,
                                          applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                                          dependants:, proceeding_types:, submission_date:)

        GrossIncome::Subtotals.new(
          applicant_gross_income_subtotals:,
          partner_gross_income_subtotals:,
          self_employments:,
          partner_self_employments:,
          dependants:,
          proceeding_types:,
          submission_date:,
        )
      end

      def partner_disposable_income_assessment(assessment:, gross_income_subtotals:, applicant_person_data:, partner_person_data:)
        applicant = PersonWrapper.new is_single: false,
                                      dependants: applicant_person_data.dependants
        partner = PersonWrapper.new is_single: false,
                                    dependants: partner_person_data.dependants

        eligible_for_childcare = Calculators::ChildcareEligibilityCalculator.call(
          applicant_incomes: [gross_income_subtotals.applicant_gross_income_subtotals, gross_income_subtotals.partner_gross_income_subtotals],
          dependants: applicant.dependants + partner.dependants, # Ensure we consider both client and partner dependants
          submission_date: assessment.submission_date,
        )
        applicant_outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
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

        applicant_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                                        disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                                        partner_allowance: partner_allowance(assessment.submission_date),
                                                                        gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                                        outgoings: applicant_outgoings)

        applicant_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                                     eligible_for_childcare:)
        partner_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                                      disposable_income_summary: assessment.partner_disposable_income_summary,
                                                                      partner_allowance: 0,
                                                                      gross_income_subtotals: gross_income_subtotals.partner_gross_income_subtotals,
                                                                      outgoings: partner_outgoings)
        partner_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                                   eligible_for_childcare:)

        DisposableResult.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(gross_income_subtotals.applicant_gross_income_subtotals,
                                                                                     applicant_outgoings,
                                                                                     partner_allowance(assessment.submission_date),
                                                                                     applicant_regular,
                                                                                     applicant_disposable),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(gross_income_subtotals.partner_gross_income_subtotals,
                                                                                   partner_outgoings,
                                                                                   0,
                                                                                   partner_regular,
                                                                                   partner_disposable),
        )
      end

      def single_disposable_income_assessment(assessment:, gross_income_subtotals:, applicant_person_data:)
        applicant = PersonWrapper.new dependants: applicant_person_data.dependants,
                                      is_single: true
        eligible_for_childcare = Calculators::ChildcareEligibilityCalculator.call(
          applicant_incomes: [gross_income_subtotals.applicant_gross_income_subtotals],
          dependants: applicant.dependants, # Ensure we consider both client and partner dependants
          submission_date: assessment.submission_date,
        )
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                      disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                      eligible_for_childcare:,
                                                      allow_negative_net: false)
        disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                              disposable_income_summary: assessment.applicant_disposable_income_summary,
                                                              partner_allowance: 0,
                                                              gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                                              outgoings:)
        regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                           eligible_for_childcare:)
        DisposableResult.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(gross_income_subtotals.applicant_gross_income_subtotals,
                                                                                     outgoings,
                                                                                     0,
                                                                                     regular,
                                                                                     disposable),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        )
      end

      def partner_allowance(submission_date)
        Threshold.value_for(:partner_allowance, at: submission_date)
      end
    end
  end
end
