module Workflows
  class MainWorkflow
    class << self
      def call(assessment:, applicant:, partner:, proceeding_type_code:)
        calculation_output = if no_means_assessment_needed?(assessment.proceeding_types, applicant.details)
                               blank_calculation_result(applicant_capitals: applicant.capitals_data,
                                                        partner_capitals: partner&.capitals_data)
                             elsif applicant.details.receives_qualifying_benefit?
                               if partner.present?
                                 PassportedWorkflow.partner(assessment:, capitals_data: applicant.capitals_data,
                                                            partner_capitals_data: partner.capitals_data,
                                                            date_of_birth: applicant.details.date_of_birth,
                                                            partner_date_of_birth: partner.details.date_of_birth,
                                                            receives_qualifying_benefit: applicant.details.receives_qualifying_benefit)
                               else
                                 PassportedWorkflow.call(assessment:, capitals_data: applicant.capitals_data,
                                                         date_of_birth: applicant.details.date_of_birth,
                                                         receives_qualifying_benefit: applicant.details.receives_qualifying_benefit)
                               end
                             else
                               NonPassportedWorkflow.call(assessment:, applicant:, partner:)
                             end
        # we can take the lower threshold from the first eligibility records as they are all the same
        lower_capital_threshold = assessment.applicant_capital_summary.eligibilities.first.lower_threshold

        new_remarks = RemarkGenerators::Orchestrator.call(employments: assessment.employments,
                                                          gross_income_summary: assessment.applicant_gross_income_summary,
                                                          outgoings: assessment.applicant_disposable_income_summary.outgoings,
                                                          liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                          lower_capital_threshold:,
                                                          child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                          assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        if partner.present?
          new_remarks += RemarkGenerators::Orchestrator.call(employments: assessment.partner_employments,
                                                             gross_income_summary: assessment.partner_gross_income_summary,
                                                             outgoings: assessment.partner_disposable_income_summary.outgoings,
                                                             liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                             lower_capital_threshold:,
                                                             child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                             assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        end
        assessment.add_remarks!(new_remarks)
        # Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit: applicant.details.receives_qualifying_benefit?,
        #                                  receives_asylum_support: applicant.details.receives_asylum_support)
        calculation_output
      end

    private

      def no_means_assessment_needed?(proceeding_types, applicant)
        proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
          applicant.receives_asylum_support
      end

      def blank_calculation_result(applicant_capitals:, partner_capitals:)
        CalculationOutput.new(capital_subtotals: CapitalSubtotals.unassessed(applicant_capitals:, partner_capitals:))
      end
    end
  end
end
