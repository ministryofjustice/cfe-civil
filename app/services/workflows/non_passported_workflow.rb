module Workflows
  class NonPassportedWorkflow
    Result = Data.define(:calculation_output, :remarks)

    class << self
      def call(assessment:, applicant:, partner:)
        unassessed_capital = unassessed_capital(assessment:, applicant:, partner:)
        gross_income_subtotals = get_gross_income_subtotals(assessment:, applicant:, partner:)

        calculation_output = if gross_income_subtotals.gross.ineligible? assessment.proceeding_types
                               CalculationOutput.new(gross_income_subtotals: gross_income_subtotals.gross,
                                                     receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                     receives_asylum_support: applicant.details.receives_asylum_support,
                                                     disposable_income_subtotals: unassessed_disposable_income(assessment:),
                                                     capital_subtotals: unassessed_capital)
                             elsif gross_income_subtotals.gross.below_the_lower_controlled_threshold?
                               CalculationOutput.new(gross_income_subtotals: gross_income_subtotals.gross,
                                                     disposable_income_subtotals: unassessed_disposable_income(assessment:),
                                                     capital_subtotals: unassessed_capital,
                                                     receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                     receives_asylum_support: applicant.details.receives_asylum_support)
                             else
                               disposable_income_subtotals = get_disposable_income_subtotals(assessment:, applicant:, partner:, gross_income_subtotals: gross_income_subtotals.gross)
                               if disposable_income_subtotals.ineligible? assessment.proceeding_types
                                 CalculationOutput.new(gross_income_subtotals: gross_income_subtotals.gross,
                                                       disposable_income_subtotals:,
                                                       capital_subtotals: unassessed_capital,
                                                       receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                       receives_asylum_support: applicant.details.receives_asylum_support)
                               else
                                 capital_subtotals = get_capital_subtotals(assessment:, applicant:, partner:, disposable_income_subtotals:)
                                 CalculationOutput.new(gross_income_subtotals: gross_income_subtotals.gross, disposable_income_subtotals:, capital_subtotals:,
                                                       receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                       receives_asylum_support: applicant.details.receives_asylum_support)
                               end
                             end

        Result.new calculation_output:, remarks: gross_income_subtotals.remarks
      end

    private

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

      def get_gross_income_subtotals(assessment:, applicant:, partner:)
        applicant_self_employments = convert_employment_details(applicant.self_employments)
        applicant_employment_details = convert_employment_details(applicant.employment_details)
        applicant_gross_income = collate_gross_income(submission_date: assessment.submission_date,
                                                      employments: applicant.employments,
                                                      gross_income_summary: assessment.applicant_gross_income_summary,
                                                      self_employments: applicant_self_employments,
                                                      state_benefits: applicant.state_benefits,
                                                      employment_details: applicant_employment_details)

        if partner.present?
          partner_self_employments = convert_employment_details(partner.self_employments)
          partner_employment_details = convert_employment_details(partner.employment_details)
          partner_gross_income = collate_gross_income(submission_date: assessment.submission_date,
                                                      employments: partner.employments,
                                                      state_benefits: partner.state_benefits,
                                                      gross_income_summary: assessment.partner_gross_income_summary,
                                                      self_employments: partner_self_employments,
                                                      employment_details: partner_employment_details)

          gross = collate_and_assess_gross_income(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                                  partner_gross_income_subtotals: partner_gross_income.person_gross_income_subtotals,
                                                  submission_date: assessment.submission_date,
                                                  level_of_help: assessment.level_of_help,
                                                  dependants: applicant.dependants + (partner.dependants || []))
          GrossIncomeSubtotals.new gross:, remarks: applicant_gross_income.remarks + partner_gross_income.remarks
        else
          gross = collate_and_assess_gross_income(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                                  partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
                                                  submission_date: assessment.submission_date,
                                                  level_of_help: assessment.level_of_help,
                                                  dependants: applicant.dependants)
          GrossIncomeSubtotals.new gross:, remarks: applicant_gross_income.remarks
        end
      end

      def get_disposable_income_subtotals(assessment:, applicant:, partner:, gross_income_subtotals:)
        disposable_result = if partner.present?
                              partner_disposable_income_assessment(assessment:,
                                                                   gross_income_subtotals:,
                                                                   applicant_person_data: applicant,
                                                                   partner_person_data: partner)
                            else
                              single_disposable_income_assessment(assessment:, gross_income_subtotals:,
                                                                  applicant_person_data: applicant)
                            end

        DisposableIncome::Subtotals.new(
          applicant_disposable_income_subtotals: disposable_result.applicant_disposable_income_subtotals,
          partner_disposable_income_subtotals: disposable_result.partner_disposable_income_subtotals,
          level_of_help: assessment.level_of_help,
          submission_date: assessment.submission_date,
        )
      end

      def get_capital_subtotals(assessment:, applicant:, partner:, disposable_income_subtotals:)
        if partner.present?
          CapitalCollatorAndAssessor.partner submission_date: assessment.submission_date,
                                             level_of_help: assessment.level_of_help,
                                             capitals_data: applicant.capitals_data,
                                             partner_capitals_data: partner.capitals_data,
                                             date_of_birth: applicant.details.date_of_birth,
                                             partner_date_of_birth: partner.details.date_of_birth,
                                             total_disposable_income: disposable_income_subtotals.combined_total_disposable_income
        else
          CapitalCollatorAndAssessor.call submission_date: assessment.submission_date,
                                          level_of_help: assessment.level_of_help,
                                          capitals_data: applicant.capitals_data,
                                          date_of_birth: applicant.details.date_of_birth,
                                          total_disposable_income: disposable_income_subtotals.combined_total_disposable_income
        end
      end

      def unassessed_capital(assessment:, applicant:, partner:)
        Capital::Unassessed.new(applicant_capitals: applicant.capitals_data,
                                partner_capitals: partner&.capitals_data,
                                submission_date: assessment.submission_date,
                                level_of_help: assessment.level_of_help)
      end

      def unassessed_disposable_income(assessment:)
        DisposableIncome::Unassessed.new(level_of_help: assessment.level_of_help,
                                         submission_date: assessment.submission_date)
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

      def collate_and_assess_gross_income(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                                          dependants:, submission_date:, level_of_help:)

        GrossIncome::Subtotals.new(
          applicant_gross_income_subtotals:,
          partner_gross_income_subtotals:,
          dependants:,
          submission_date:,
          level_of_help:,
        )
      end

      # local define to pass back disposable subtotals
      DisposableResult = Data.define(:applicant_disposable_income_subtotals,
                                     :partner_disposable_income_subtotals)

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
                                                                outgoings: applicant_person_data.outgoings,
                                                                eligible_for_childcare:,
                                                                state_benefits: applicant_person_data.state_benefits,
                                                                total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                                allow_negative_net: true)
        partner_outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                              person: partner,
                                                              gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                              outgoings: partner_person_data.outgoings,
                                                              eligible_for_childcare:,
                                                              state_benefits: partner_person_data.state_benefits,
                                                              total_gross_income: gross_income_subtotals.partner_gross_income_subtotals.total_gross_income,
                                                              allow_negative_net: true)

        applicant_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze)
        applicant_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                                     eligible_for_childcare:)

        partner_disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze)
        partner_regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                                   eligible_for_childcare:)

        DisposableResult.new(
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(
            total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
            disposable_employment_deductions: gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals.disposable_employment_deductions,
            outgoings: applicant_outgoings,
            partner_allowance: partner_allowance(assessment.submission_date),
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

      def single_disposable_income_assessment(assessment:, gross_income_subtotals:, applicant_person_data:)
        applicant = PersonWrapper.new dependants: applicant_person_data.dependants,
                                      is_single: true
        eligible_for_childcare = Calculators::ChildcareEligibilityCalculator.call(
          applicant_incomes: [gross_income_subtotals.applicant_gross_income_subtotals],
          dependants: applicant.dependants,
          submission_date: assessment.submission_date,
        )
        outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                      person: applicant,
                                                      gross_income_summary: assessment.applicant_gross_income_summary.freeze,
                                                      outgoings: applicant_person_data.outgoings,
                                                      eligible_for_childcare:,
                                                      state_benefits: applicant_person_data.state_benefits,
                                                      total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                      allow_negative_net: false)
        disposable = Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze)
        regular = Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.applicant_gross_income_summary.freeze,
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
