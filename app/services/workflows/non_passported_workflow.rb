module Workflows
  class NonPassportedWorkflow
    Result = Data.define(:calculation_output, :remarks, :assessment_result)

    class << self
      InternalResult = Data.define(:calculation_output, :assessment_result)

      def with_partner(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        unassessed_capital = Capital::UnassessedWithPartner.new(applicant_capitals: applicant.capitals_data,
                                                                partner_capitals: partner.capitals_data,
                                                                submission_date:,
                                                                level_of_help:)
        gross_income_subtotals = get_gross_income_subtotals_with_partner(applicant:, partner:, submission_date:)
        disposable_income_subtotals = get_disposable_income_subtotals_with_partner(applicant:, partner:, gross_income_subtotals: gross_income_subtotals.gross,
                                                                                   submission_date:, level_of_help:)
        capital_subtotals = CapitalCollatorAndAssessor.partner submission_date:,
                                                               level_of_help:,
                                                               capitals_data: applicant.capitals_data,
                                                               partner_capitals_data: partner.capitals_data,
                                                               date_of_birth: applicant.details.date_of_birth,
                                                               partner_date_of_birth: partner.details.date_of_birth,
                                                               total_disposable_income: disposable_income_subtotals.combined_total_disposable_income

        internal_result = result(gross_income_subtotals: gross_income_subtotals.gross, disposable_income_subtotals:, capital_subtotals:, unassessed_capital:,
                                 proceeding_types:, submission_date:, level_of_help:)
        Result.new calculation_output: internal_result.calculation_output, remarks: gross_income_subtotals.remarks, assessment_result: internal_result.assessment_result
      end

      def without_partner(applicant:, submission_date:, level_of_help:, proceeding_types:)
        unassessed_capital = Capital::Unassessed.new(applicant_capitals: applicant.capitals_data,
                                                     submission_date:,
                                                     level_of_help:)
        gross_income_subtotals = get_gross_income_subtotals(applicant:, submission_date:)
        disposable_income_subtotals = get_disposable_income_subtotals(applicant:, gross_income_subtotals: gross_income_subtotals.gross, level_of_help:, submission_date:)
        capital_subtotals = CapitalCollatorAndAssessor.call submission_date:,
                                                            level_of_help:,
                                                            capitals_data: applicant.capitals_data,
                                                            date_of_birth: applicant.details.date_of_birth,
                                                            total_disposable_income: disposable_income_subtotals.combined_total_disposable_income

        internal_result = result(gross_income_subtotals: gross_income_subtotals.gross, disposable_income_subtotals:, capital_subtotals:, unassessed_capital:,
                                 proceeding_types:, submission_date:, level_of_help:)
        Result.new calculation_output: internal_result.calculation_output, remarks: gross_income_subtotals.remarks, assessment_result: internal_result.assessment_result
      end

    private

      def result(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:, unassessed_capital:, proceeding_types:,
                 submission_date:, level_of_help:)
        if gross_income_subtotals.ineligible? proceeding_types
          calculation_output = CalculationOutput.new(gross_income_subtotals:,
                                                     disposable_income_subtotals: DisposableIncome::Unassessed.new(level_of_help:,
                                                                                                                   submission_date:),
                                                     capital_subtotals: unassessed_capital)
          InternalResult.new(calculation_output:, assessment_result: :ineligible)
        elsif disposable_income_subtotals.ineligible? proceeding_types
          calculation_output = CalculationOutput.new(gross_income_subtotals:,
                                                     disposable_income_subtotals:,
                                                     capital_subtotals: unassessed_capital)
          InternalResult.new(calculation_output:, assessment_result: :ineligible)
        else
          calculation_output = CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:)
          capital_result = capital_subtotals.summarized_assessment_result(proceeding_types)
          disposable_result = disposable_income_subtotals.summarized_assessment_result(proceeding_types)
          if capital_result != :eligible
            InternalResult.new(calculation_output:, assessment_result: capital_result)
          else
            InternalResult.new(calculation_output:, assessment_result: disposable_result)
          end
        end
      end

      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :entitles_employment_allowance?,
                                   :entitles_childcare_allowance?,
                                   :monthly_benefits_in_kind,
                                   :monthly_national_insurance,
                                   :monthly_prisoner_levy,
                                   :monthly_student_debt_repayment,
                                   :employment_name,
                                   :employment_payments)

      GrossIncomeSubtotals = Data.define(:gross, :remarks)

      def get_gross_income_subtotals(applicant:, submission_date:)
        applicant_self_employments = convert_employment_details(applicant.self_employments)
        applicant_employment_details = convert_employment_details(applicant.employment_details)
        applicant_gross_income = collate_gross_income(submission_date:,
                                                      employments: applicant.employments,
                                                      gross_income_summary: applicant.gross_income_summary,
                                                      self_employments: applicant_self_employments,
                                                      state_benefits: applicant.state_benefits,
                                                      employment_details: applicant_employment_details)

        gross = GrossIncome::Subtotals.new(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                           partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
                                           dependants: applicant.dependants,
                                           submission_date:)
        GrossIncomeSubtotals.new gross:, remarks: applicant_gross_income.remarks
      end

      def get_gross_income_subtotals_with_partner(applicant:, partner:, submission_date:)
        applicant_self_employments = convert_employment_details(applicant.self_employments)
        applicant_employment_details = convert_employment_details(applicant.employment_details)
        applicant_gross_income = collate_gross_income(submission_date:,
                                                      employments: applicant.employments,
                                                      gross_income_summary: applicant.gross_income_summary,
                                                      self_employments: applicant_self_employments,
                                                      state_benefits: applicant.state_benefits,
                                                      employment_details: applicant_employment_details)

        partner_self_employments = convert_employment_details(partner.self_employments)
        partner_employment_details = convert_employment_details(partner.employment_details)
        partner_gross_income = collate_gross_income(submission_date:,
                                                    employments: partner.employments,
                                                    state_benefits: partner.state_benefits,
                                                    gross_income_summary: partner.gross_income_summary,
                                                    self_employments: partner_self_employments,
                                                    employment_details: partner_employment_details)

        gross = GrossIncome::Subtotals.new(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                           partner_gross_income_subtotals: partner_gross_income.person_gross_income_subtotals,
                                           dependants: applicant.dependants + partner.dependants,
                                           submission_date:)
        GrossIncomeSubtotals.new gross:, remarks: applicant_gross_income.remarks + partner_gross_income.remarks
      end

      def get_disposable_income_subtotals(applicant:, gross_income_subtotals:, submission_date:, level_of_help:)
        disposable_result = single_disposable_income_assessment(submission_date:,
                                                                gross_income_subtotals:,
                                                                applicant_person_data: applicant)

        DisposableIncome::Subtotals.new(
          applicant_disposable_income_subtotals: disposable_result.applicant_disposable_income_subtotals,
          partner_disposable_income_subtotals: disposable_result.partner_disposable_income_subtotals,
          level_of_help:,
          submission_date:,
        )
      end

      def get_disposable_income_subtotals_with_partner(applicant:, partner:, gross_income_subtotals:, submission_date:, level_of_help:)
        disposable_result = partner_disposable_income_assessment(submission_date:,
                                                                 gross_income_subtotals:,
                                                                 applicant_person_data: applicant,
                                                                 partner_person_data: partner)

        DisposableIncome::Subtotals.new(
          applicant_disposable_income_subtotals: disposable_result.applicant_disposable_income_subtotals,
          partner_disposable_income_subtotals: disposable_result.partner_disposable_income_subtotals,
          level_of_help:,
          submission_date:,
        )
      end

      # local define for employment and monthly_values
      EmploymentResult = Data.define(:employment, :values, :payments, :remarks)

      EmploymentDataAndRemarks = Data.define(:employment_data, :remarks)

      def convert_employment_payments(employments, submission_date)
        answers = employments.map do
          monthly_equivalent_payments = Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(_1.employment_payments)
          remarks_and_values = Calculators::EmploymentMonthlyValueCalculator.call(_1, submission_date, monthly_equivalent_payments)
          EmploymentResult.new employment: _1, values: remarks_and_values.values, payments: remarks_and_values.payments, remarks: remarks_and_values.remarks
        end

        employment_data = answers.map do
          EmploymentData.new(monthly_tax: _1.values.fetch(:monthly_tax),
                             monthly_gross_income: _1.values.fetch(:monthly_gross_income),
                             monthly_national_insurance: _1.values.fetch(:monthly_national_insurance),
                             monthly_prisoner_levy: _1.values.fetch(:monthly_prisoner_levy),
                             monthly_student_debt_repayment: _1.values.fetch(:monthly_student_debt_repayment),
                             entitles_employment_allowance?: _1.employment.entitles_employment_allowance?,
                             entitles_childcare_allowance?: _1.employment.entitles_childcare_allowance?,
                             client_id: _1.employment.client_id,
                             monthly_benefits_in_kind: _1.values.fetch(:monthly_benefits_in_kind),
                             employment_name: _1.employment.name,
                             employment_payments: _1.payments)
        end

        EmploymentDataAndRemarks.new(employment_data:, remarks: answers.map(&:remarks).flatten)
      end

      def convert_employment_details(employment_details)
        employment_details.map do |detail|
          monthly_gross_income = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.gross)
          monthly_national_insurance = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.national_insurance)
          monthly_prisoner_levy = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.prisoner_levy)
          monthly_student_debt_repayment = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.student_debt_repayment)
          monthly_tax = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.tax)
          monthly_benefits_in_kind = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.benefits_in_kind)

          EmploymentData.new(monthly_tax:,
                             monthly_gross_income:,
                             monthly_national_insurance:,
                             monthly_prisoner_levy:,
                             monthly_student_debt_repayment:,
                             entitles_employment_allowance?: detail.income.entitles_employment_allowance?,
                             entitles_childcare_allowance?: detail.income.entitles_childcare_allowance?,
                             client_id: detail.client_reference,
                             monthly_benefits_in_kind:,
                             employment_name: nil,
                             employment_payments: [])
        end
      end

      def collate_gross_income(submission_date:, employments:, gross_income_summary:, self_employments:, employment_details:, state_benefits:)
        converted_employments_and_remarks = convert_employment_payments(employments, submission_date)
        gross_result = Collators::GrossIncomeCollator.call(submission_date:,
                                                           self_employments:,
                                                           employment_details:,
                                                           employments: converted_employments_and_remarks.employment_data,
                                                           gross_income_summary:,
                                                           state_benefits:)
        Collators::GrossIncomeCollator::Result.new person_gross_income_subtotals: gross_result.person_gross_income_subtotals,
                                                   remarks: gross_result.remarks + converted_employments_and_remarks.remarks
      end

      # local define to pass back disposable subtotals
      DisposableResult = Data.define(:applicant_disposable_income_subtotals,
                                     :partner_disposable_income_subtotals)

      def partner_disposable_income_assessment(submission_date:, gross_income_subtotals:, applicant_person_data:, partner_person_data:)
        applicant = PersonWrapper.new is_single: false,
                                      dependants: applicant_person_data.dependants
        partner = PersonWrapper.new is_single: false,
                                    dependants: partner_person_data.dependants

        eligible_for_childcare = Calculators::ChildcareEligibilityCalculator.call(
          applicant_incomes: [gross_income_subtotals.applicant_gross_income_subtotals, gross_income_subtotals.partner_gross_income_subtotals],
          dependants: applicant.dependants + partner.dependants, # Ensure we consider both client and partner dependants
          submission_date:,
        )
        applicant_outgoings = Collators::OutgoingsCollator.call(submission_date:,
                                                                person: applicant,
                                                                gross_income_summary: applicant_person_data.gross_income_summary,
                                                                outgoings: applicant_person_data.outgoings,
                                                                eligible_for_childcare:,
                                                                state_benefits: applicant_person_data.state_benefits,
                                                                total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                                allow_negative_net: true)
        partner_outgoings = Collators::OutgoingsCollator.call(submission_date:,
                                                              person: partner,
                                                              gross_income_summary: partner_person_data.gross_income_summary,
                                                              outgoings: partner_person_data.outgoings,
                                                              eligible_for_childcare:,
                                                              state_benefits: partner_person_data.state_benefits,
                                                              total_gross_income: gross_income_subtotals.partner_gross_income_subtotals.total_gross_income,
                                                              allow_negative_net: true)

        applicant_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: applicant_person_data.gross_income_summary)
        applicant_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: applicant_person_data.gross_income_summary,
                                                                     eligible_for_childcare:)

        partner_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: partner_person_data.gross_income_summary)
        partner_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: partner_person_data.gross_income_summary,
                                                                   eligible_for_childcare:)

        DisposableResult.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(
            total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
            disposable_employment_deductions: gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals.disposable_employment_deductions,
            outgoings: applicant_outgoings,
            partner_allowance: partner_allowance(submission_date),
            regular: applicant_regular,
            disposable: applicant_disposable,
          ),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(
            total_gross_income: gross_income_subtotals.partner_gross_income_subtotals.total_gross_income,
            disposable_employment_deductions: gross_income_subtotals.partner_gross_income_subtotals.employment_income_subtotals.disposable_employment_deductions,
            outgoings: partner_outgoings,
            partner_allowance: 0,
            regular: partner_regular,
            disposable: partner_disposable,
          ),
        )
      end

      def single_disposable_income_assessment(gross_income_subtotals:, applicant_person_data:, submission_date:)
        applicant = PersonWrapper.new dependants: applicant_person_data.dependants,
                                      is_single: true
        eligible_for_childcare = Calculators::ChildcareEligibilityCalculator.call(
          applicant_incomes: [gross_income_subtotals.applicant_gross_income_subtotals],
          dependants: applicant.dependants,
          submission_date:,
        )
        outgoings = Collators::OutgoingsCollator.call(submission_date:,
                                                      person: applicant,
                                                      gross_income_summary: applicant_person_data.gross_income_summary,
                                                      outgoings: applicant_person_data.outgoings,
                                                      eligible_for_childcare:,
                                                      state_benefits: applicant_person_data.state_benefits,
                                                      total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                      allow_negative_net: false)
        disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: applicant_person_data.gross_income_summary)
        regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: applicant_person_data.gross_income_summary,
                                                           eligible_for_childcare:)
        DisposableResult.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(
            total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
            disposable_employment_deductions: gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals.disposable_employment_deductions,
            outgoings:,
            partner_allowance: 0,
            regular:,
            disposable:,
          ),
          partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        )
      end

      def partner_allowance(submission_date)
        Threshold.value_for(:partner_allowance, at: submission_date)
      end
    end
  end
end
