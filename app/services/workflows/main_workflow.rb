module Workflows
  class MainWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        populate_eligibility_records(assessment:)
        calculation_output = if no_means_assessment_needed?(assessment.proceeding_types, applicant.details)
                               blank_calculation_result(proceeding_types: assessment.proceeding_types,
                                                        submission_date: assessment.submission_date,
                                                        level_of_help: assessment.level_of_help,
                                                        applicant_capitals: applicant.capitals_data,
                                                        partner_capitals: partner&.capitals_data,
                                                        assessment:,
                                                        receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                        receives_asylum_support: applicant.details.receives_asylum_support)
                             elsif applicant.details.receives_qualifying_benefit?
                               if partner.present?
                                 PassportedWorkflow.partner(assessment:, capitals_data: applicant.capitals_data,
                                                            partner_capitals_data: partner.capitals_data,
                                                            date_of_birth: applicant.details.date_of_birth,
                                                            level_of_help: assessment.level_of_help,
                                                            submission_date: assessment.submission_date,
                                                            partner_date_of_birth: partner.details.date_of_birth,
                                                            receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                            receives_asylum_support: applicant.details.receives_asylum_support)
                               else
                                 PassportedWorkflow.call(assessment:, capitals_data: applicant.capitals_data,
                                                         date_of_birth: applicant.details.date_of_birth,
                                                         submission_date: assessment.submission_date,
                                                         level_of_help: assessment.level_of_help,
                                                         receives_qualifying_benefit: applicant.details.receives_qualifying_benefit,
                                                         receives_asylum_support: applicant.details.receives_asylum_support)
                               end
                             else
                               NonPassportedWorkflow.call(assessment:, applicant:, partner:)
                             end
        # we can take the lower threshold from the first eligibility records as they are all the same
        # lower_capital_threshold = assessment.applicant_capital_summary.eligibilities.first.lower_threshold
        lower_capital_threshold = calculation_output.capital_subtotals.eligibilities.first.lower_threshold

        new_remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                          gross_income_summary: assessment.applicant_gross_income_summary,
                                                          outgoings: assessment.applicant_disposable_income_summary.outgoings,
                                                          liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                          lower_capital_threshold:,
                                                          child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                          assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        if partner.present?
          new_remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                             gross_income_summary: assessment.partner_gross_income_summary,
                                                             outgoings: assessment.partner_disposable_income_summary.outgoings,
                                                             liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                             lower_capital_threshold:,
                                                             child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                             assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        end
        assessment.add_remarks!(new_remarks)
        calculation_output
      end

    private

      def populate_eligibility_records(assessment:)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment)
      end

      def no_means_assessment_needed?(proceeding_types, applicant)
        proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
          applicant.receives_asylum_support
      end

      def blank_calculation_result(proceeding_types:, applicant_capitals:, partner_capitals:, level_of_help:, submission_date:,
                                   assessment:, receives_qualifying_benefit:, receives_asylum_support:)
        CalculationOutput.new(capital_subtotals: Capital::Unassessed.new(applicant_capitals:, partner_capitals:, submission_date:, level_of_help:, proceeding_types:),
                              gross_income_subtotals: GrossIncome::Unassessed.new(proceeding_types),
                              assessment:, receives_qualifying_benefit:, receives_asylum_support:,
                              disposable_income_subtotals: DisposableIncome::Unassessed.new(proceeding_types:, level_of_help:, submission_date:))
      end
    end
  end
end
