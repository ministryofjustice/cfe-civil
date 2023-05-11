module Workflows
  class MainWorkflow
    class << self
      def call(assessment, self_employment = nil)
        version_5_verification(assessment)
        calculation_output = if no_means_assessment_needed?(assessment)
                               blank_calculation_result
                             elsif assessment.applicant.receives_qualifying_benefit?
                               PassportedWorkflow.call(assessment)
                             else
                               NonPassportedWorkflow.call(assessment, self_employment)
                             end
        RemarkGenerators::Orchestrator.call(assessment, calculation_output.capital_subtotals.combined_assessed_capital)
        Assessors::MainAssessor.call(assessment)
        calculation_output
      end

    private

      def version_5_verification(assessment)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment)
      end

      def no_means_assessment_needed?(assessment)
        assessment.proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
          assessment.applicant.receives_asylum_support
      end

      def blank_calculation_result
        CalculationOutput.new
      end
    end
  end
end
