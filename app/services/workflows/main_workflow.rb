module Workflows
  class MainWorkflow < BaseWorkflowService
    def call
      version_5_verification(assessment)
      calculation_output = if applicant_passported?
                             PassportedWorkflow.call(assessment)
                           else
                             NonPassportedWorkflow.call(assessment)
                           end
      RemarkGenerators::Orchestrator.call(assessment)
      Assessors::MainAssessor.call(assessment)
      calculation_output
    end

  private

    def applicant_passported?
      applicant.receives_qualifying_benefit?
    end

    def version_5_verification(assessment)
      Utilities::ProceedingTypeThresholdPopulator.call(assessment)
      Creators::EligibilitiesCreator.call(assessment)
    end
  end
end
