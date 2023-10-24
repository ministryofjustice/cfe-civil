module Workflows
  class MainWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        calculation_output = if non_means_tested?(proceeding_types: assessment.proceeding_types, applicant:, submission_date: assessment.submission_date)
                               blank_calculation_result(submission_date: assessment.submission_date,
                                                        level_of_help: assessment.level_of_help,
                                                        applicant_capitals: applicant.capitals_data,
                                                        partner_capitals: partner&.capitals_data,
                                                        receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                        receives_asylum_support: applicant.details.receives_asylum_support)
                             elsif applicant.details.receives_qualifying_benefit?
                               if partner.present?
                                 PassportedWorkflow.partner(capitals_data: applicant.capitals_data,
                                                            partner_capitals_data: partner.capitals_data,
                                                            date_of_birth: applicant.details.date_of_birth,
                                                            level_of_help: assessment.level_of_help,
                                                            submission_date: assessment.submission_date,
                                                            partner_date_of_birth: partner.details.date_of_birth,
                                                            receives_asylum_support: applicant.details.receives_asylum_support)
                               else
                                 PassportedWorkflow.call(capitals_data: applicant.capitals_data,
                                                         date_of_birth: applicant.details.date_of_birth,
                                                         submission_date: assessment.submission_date,
                                                         level_of_help: assessment.level_of_help,
                                                         receives_asylum_support: applicant.details.receives_asylum_support)
                               end
                             else
                               result = NonPassportedWorkflow.call(assessment:, applicant:, partner:)
                               assessment.add_remarks! result.remarks
                               result.calculation_output
                             end
        calculation_output.tap do
          # we can take the lower threshold from the first eligibility records as they are all the same
          lower_capital_threshold = calculation_output.capital_subtotals.eligibilities(assessment.proceeding_types).first.lower_threshold
          assessed_capital = calculation_output.capital_subtotals.combined_assessed_capital

          remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                        gross_income_summary: assessment.applicant_gross_income_summary,
                                                        outgoings: applicant.outgoings,
                                                        liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                        state_benefits: applicant.state_benefits,
                                                        lower_capital_threshold:,
                                                        child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                        assessed_capital:)
          if partner.present?
            remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                           gross_income_summary: assessment.partner_gross_income_summary,
                                                           outgoings: partner.outgoings,
                                                           liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                           lower_capital_threshold:,
                                                           state_benefits: partner.state_benefits,
                                                           child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                           assessed_capital:)
          end
          assessment.add_remarks!(remarks)
        end
      end

    private

      def non_means_tested?(proceeding_types:, applicant:, submission_date:)
        # skip proceeding types check if applicant receives asylum support after MTR go-live date
        if asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
          applicant.details.receives_asylum_support
        else
          proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } && applicant.details.receives_asylum_support
        end
      end

      def asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
        !!Threshold.value_for(:asylum_support_is_non_means_tested_for_all_matter_types, at: submission_date)
      end

      def blank_calculation_result(applicant_capitals:, partner_capitals:, level_of_help:, submission_date:,
                                   receives_qualifying_benefit:, receives_asylum_support:)
        CalculationOutput.new(
          receives_qualifying_benefit:, receives_asylum_support:,
          gross_income_subtotals: GrossIncome::Unassessed.new,
          disposable_income_subtotals: DisposableIncome::Unassessed.new(level_of_help:, submission_date:),
          capital_subtotals: Capital::Unassessed.new(applicant_capitals:, partner_capitals:, submission_date:, level_of_help:)
        )
      end
    end
  end
end
