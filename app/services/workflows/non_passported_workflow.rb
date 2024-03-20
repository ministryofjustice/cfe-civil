module Workflows
  class NonPassportedWorkflow
    class << self
      InternalResult = Data.define(:calculation_output, :assessment_result, :sections)

      def with_partner(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        gross_income_subtotals = get_gross_income_subtotals_with_partner(applicant:, partner:, submission_date:, level_of_help:)
        disposable_income_subtotals = get_disposable_income_subtotals_with_partner(applicant:, partner:, gross_income_subtotals: gross_income_subtotals.gross,
                                                                                   submission_date:, level_of_help:)
        capital_subtotals = assess_with_partner submission_date:,
                                                level_of_help:,
                                                capitals_data: applicant.capitals_data,
                                                partner_capitals_data: partner.capitals_data,
                                                date_of_birth: applicant.details.date_of_birth,
                                                partner_date_of_birth: partner.details.date_of_birth,
                                                total_disposable_income: disposable_income_subtotals.combined_total_disposable_income

        internal_result = result(submission_date:, level_of_help:,
                                 gross_income_subtotals: gross_income_subtotals.gross, disposable_income_subtotals:, capital_subtotals:,
                                 proceeding_types:)
        WorkflowResult.new calculation_output: internal_result.calculation_output,
                           remarks: gross_income_subtotals.remarks,
                           assessment_result: internal_result.assessment_result,
                           sections: internal_result.sections
      end

      def without_partner(applicant:, submission_date:, level_of_help:, proceeding_types:)
        gross_income_subtotals = get_gross_income_subtotals(applicant:, submission_date:, level_of_help:)
        disposable_income_subtotals = get_disposable_income_subtotals(applicant:, gross_income_subtotals: gross_income_subtotals.gross, level_of_help:, submission_date:)
        capital_subtotals = assess_without_partner submission_date:,
                                                   level_of_help:,
                                                   capitals_data: applicant.capitals_data,
                                                   date_of_birth: applicant.details.date_of_birth,
                                                   total_disposable_income: disposable_income_subtotals.combined_total_disposable_income

        internal_result = result(submission_date:, level_of_help:,
                                 gross_income_subtotals: gross_income_subtotals.gross, disposable_income_subtotals:, capital_subtotals:,
                                 proceeding_types:)
        WorkflowResult.new calculation_output: internal_result.calculation_output,
                           remarks: gross_income_subtotals.remarks,
                           assessment_result: internal_result.assessment_result,
                           sections: internal_result.sections
      end

    private

      def assess_with_partner(submission_date:, level_of_help:, capitals_data:, partner_capitals_data:, date_of_birth:, partner_date_of_birth:,
                              total_disposable_income:)
        applicant_value = Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth:)
        partner_value = Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth: partner_date_of_birth)

        applicant_subtotals = Collators::CapitalCollator.collate_applicant_capital(submission_date:,
                                                                                   level_of_help:,
                                                                                   pensioner_capital_disregard: [applicant_value, partner_value].max,
                                                                                   capitals_data:)
        partner_subtotals = Collators::CapitalCollator.collate_partner_capital(submission_date:,
                                                                               level_of_help:,
                                                                               pensioner_capital_disregard: applicant_subtotals.pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied,
                                                                               capitals_data: partner_capitals_data)
        Capital::SubtotalsWithPartner.new(
          applicant_capital_subtotals: applicant_subtotals,
          partner_capital_subtotals: partner_subtotals,
          level_of_help:,
          submission_date:,
        )
      end

      def assess_without_partner(submission_date:, level_of_help:, capitals_data:, date_of_birth:, total_disposable_income:)
        applicant_subtotals = Collators::CapitalCollator.collate_applicant_capital(
          submission_date:,
          level_of_help:,
          pensioner_capital_disregard: Calculators::PensionerCapitalDisregardCalculator.non_passported_value(submission_date:, total_disposable_income:, date_of_birth:),
          capitals_data:,
        )

        Capital::Subtotals.new(
          applicant_capital_subtotals: applicant_subtotals,
          level_of_help:,
          submission_date:,
        )
      end

      def result(submission_date:, level_of_help:, gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:, proceeding_types:)
        calculation_output = CalculationOutput.new(submission_date:,
                                                   level_of_help:,
                                                   gross_income_subtotals:,
                                                   disposable_income_subtotals:,
                                                   capital_subtotals:)
        capital_result = capital_subtotals.summarized_assessment_result(proceeding_types)
        if gross_income_subtotals.ineligible?(proceeding_types)
          if capital_result == :ineligible
            InternalResult.new(calculation_output:, assessment_result: :ineligible, sections: %i[gross capital])
          else
            InternalResult.new(calculation_output:, assessment_result: :ineligible, sections: [:gross])
          end
        elsif gross_income_subtotals.below_the_lower_controlled_threshold?
          InternalResult.new(calculation_output:, assessment_result: :eligible, sections: [:gross])
        else
          disposable_result = disposable_income_subtotals.summarized_assessment_result(proceeding_types)
          if disposable_income_subtotals.ineligible? proceeding_types
            if capital_result == :ineligible
              InternalResult.new(calculation_output:, assessment_result: :ineligible, sections: %i[disposable capital])
            else
              InternalResult.new(calculation_output:, assessment_result: :ineligible, sections: [:disposable])
            end
          elsif capital_result != :eligible
            InternalResult.new(calculation_output:, assessment_result: capital_result, sections: [:capital])
          else
            InternalResult.new(calculation_output:, assessment_result: disposable_result, sections: [:disposable])
          end
        end
      end

      GrossIncomeSubtotals = Data.define(:gross, :remarks)

      def get_gross_income_subtotals(applicant:, submission_date:, level_of_help:)
        applicant_gross_income = Collators::GrossIncomeCollator.call(submission_date:, person: applicant)

        gross = GrossIncome::Subtotals.new(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                           partner_gross_income_subtotals: PersonGrossIncomeSubtotals.blank,
                                           dependants: applicant.dependants,
                                           submission_date:, level_of_help:)
        GrossIncomeSubtotals.new gross:, remarks: { client: applicant_gross_income.remarks, partner: [] }
      end

      def get_gross_income_subtotals_with_partner(applicant:, partner:, submission_date:, level_of_help:)
        applicant_gross_income = Collators::GrossIncomeCollator.call(submission_date:, person: applicant)
        partner_gross_income = Collators::GrossIncomeCollator.call(submission_date:, person: partner)

        gross = GrossIncome::Subtotals.new(applicant_gross_income_subtotals: applicant_gross_income.person_gross_income_subtotals,
                                           partner_gross_income_subtotals: partner_gross_income.person_gross_income_subtotals,
                                           dependants: applicant.dependants + partner.dependants,
                                           submission_date:, level_of_help:)
        GrossIncomeSubtotals.new gross:, remarks: { client: applicant_gross_income.remarks, partner: partner_gross_income.remarks }
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
                                                                regular_transactions: applicant_person_data.regular_transactions,
                                                                cash_transactions: applicant_person_data.cash_transactions,
                                                                outgoings: applicant_person_data.outgoings,
                                                                eligible_for_childcare:,
                                                                state_benefits: applicant_person_data.state_benefits,
                                                                total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                                allow_negative_net: true)
        partner_outgoings = Collators::OutgoingsCollator.call(submission_date:,
                                                              person: partner,
                                                              cash_transactions: partner_person_data.cash_transactions,
                                                              regular_transactions: partner_person_data.regular_transactions,
                                                              outgoings: partner_person_data.outgoings,
                                                              eligible_for_childcare:,
                                                              state_benefits: partner_person_data.state_benefits,
                                                              total_gross_income: gross_income_subtotals.partner_gross_income_subtotals.total_gross_income,
                                                              allow_negative_net: true)

        applicant_disposable = Collators::DisposableIncomeCollator.call(cash_transactions: applicant_person_data.cash_transactions)
        applicant_regular = Collators::RegularOutgoingsCollator.call(regular_transactions: applicant_person_data.regular_transactions,
                                                                     eligible_for_childcare:)

        partner_disposable = Collators::DisposableIncomeCollator.call(cash_transactions: partner_person_data.cash_transactions)
        partner_regular = Collators::RegularOutgoingsCollator.call(regular_transactions: partner_person_data.regular_transactions,
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
                                                      outgoings: applicant_person_data.outgoings,
                                                      regular_transactions: applicant_person_data.regular_transactions,
                                                      eligible_for_childcare:,
                                                      cash_transactions: applicant_person_data.cash_transactions,
                                                      state_benefits: applicant_person_data.state_benefits,
                                                      total_gross_income: gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
                                                      allow_negative_net: false)
        disposable = Collators::DisposableIncomeCollator.call(cash_transactions: applicant_person_data.cash_transactions)
        regular = Collators::RegularOutgoingsCollator.call(regular_transactions: applicant_person_data.regular_transactions,
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
