module Workflows
  class MainWorkflow
    class << self
      def call(assessment:, applicant:, partner:)
        populate_eligibility_records(assessment:, dependants: applicant.dependants, partner_dependants: partner&.dependants || [])
        calculation_output = if no_means_assessment_needed?(assessment)
                               blank_calculation_result(applicant:, partner:)
                             elsif assessment.applicant.receives_qualifying_benefit?
                               PassportedWorkflow.call(assessment:, vehicles: applicant.vehicles, partner_vehicles: partner&.vehicles || [])
                             else
                               NonPassportedWorkflow.call(assessment:, applicant:, partner:)
                             end
        # we can take the lower threshold from the first eligibility records as they are all the same
        lower_capital_threshold = assessment.applicant_capital_summary.eligibilities.first.lower_threshold

        RemarkGenerators::Orchestrator.call(assessment:, employments: assessment.employments,
                                            gross_income_summary: assessment.applicant_gross_income_summary,
                                            disposable_income_summary: assessment.applicant_disposable_income_summary,
                                            capital_summary: assessment.applicant_capital_summary,
                                            lower_capital_threshold:,
                                            assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        if partner.present?
          RemarkGenerators::Orchestrator.call(assessment:, employments: assessment.partner_employments,
                                              gross_income_summary: assessment.partner_gross_income_summary,
                                              disposable_income_summary: assessment.partner_disposable_income_summary,
                                              capital_summary: assessment.partner_capital_summary,
                                              lower_capital_threshold:,
                                              assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        end
        Assessors::MainAssessor.call(assessment)
        calculation_output
      end

    private

      def populate_eligibility_records(assessment:, dependants:, partner_dependants:)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment:, client_dependants: dependants, partner_dependants:)
      end

      def no_means_assessment_needed?(assessment)
        assessment.proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
          assessment.applicant.receives_asylum_support
      end

      def blank_calculation_result(applicant:, partner:)
        CalculationOutput.new(capital_subtotals: CapitalSubtotals.unassessed(applicant:, partner:))
      end
    end
  end
end
