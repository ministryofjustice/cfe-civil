module Workflows
  class MainWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        populate_eligibility_records(assessment:, dependants: applicant.dependants, partner_dependants: partner&.dependants || [])
        calculation_output = if no_means_assessment_needed?(assessment.proceeding_types, applicant.details)
                               blank_calculation_result(applicant:,
                                                        partner:,
                                                        applicant_properties: assessment.applicant_capital_summary.properties,
                                                        partner_properties: assessment.partner_capital_summary&.properties || [])
                             elsif applicant.details.receives_qualifying_benefit?
                               if partner.present?
                                 PassportedWorkflow.partner(assessment:, vehicles: applicant.vehicles,
                                                            partner_vehicles: partner.vehicles,
                                                            date_of_birth: applicant.details.date_of_birth,
                                                            partner_date_of_birth: partner.details.date_of_birth,
                                                            receives_qualifying_benefit: applicant.details.receives_qualifying_benefit)
                               else
                                 PassportedWorkflow.call(assessment:, vehicles: applicant.vehicles,
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
                                                          capital_summary: assessment.applicant_capital_summary,
                                                          lower_capital_threshold:,
                                                          child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                          assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        if partner.present?
          new_remarks += RemarkGenerators::Orchestrator.call(employments: assessment.partner_employments,
                                                             gross_income_summary: assessment.partner_gross_income_summary,
                                                             outgoings: assessment.partner_disposable_income_summary.outgoings,
                                                             capital_summary: assessment.partner_capital_summary,
                                                             lower_capital_threshold:,
                                                             child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                             assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        end
        assessment.add_remarks!(new_remarks)
        Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit: applicant.details.receives_qualifying_benefit?,
                                         receives_asylum_support: applicant.details.receives_asylum_support)
        calculation_output
      end

    private

      def populate_eligibility_records(assessment:, dependants:, partner_dependants:)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment:, client_dependants: dependants, partner_dependants:)
      end

      def no_means_assessment_needed?(proceeding_types, applicant)
        proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
          applicant.receives_asylum_support
      end

      def blank_calculation_result(applicant:, partner:, applicant_properties:, partner_properties:)
        CalculationOutput.new(capital_subtotals: CapitalSubtotals.unassessed(applicant:, partner:, applicant_properties:, partner_properties:))
      end
    end
  end
end
