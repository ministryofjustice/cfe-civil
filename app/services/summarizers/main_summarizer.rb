module Summarizers
  class MainSummarizer
    class << self
      def call(assessment:, applicant:, partner:)
        populate_eligibility_records(assessment:, dependants: applicant.dependants, partner_dependants: partner&.dependants || [])

        assessment.proceeding_types.map(&:ccms_code).map do |ptc|
          Workflows::MainWorkflow.call(assessment:,
                                       applicant:,
                                       partner:,
                                       proceeding_type_code: ptc).tap do |calculation_output|
            Summarizers::AssessmentProceedingTypeSummarizer.call(calculation_output:, proceeding_type_code: ptc,
                                                               receives_qualifying_benefit: applicant.details.receives_qualifying_benefit?,
                                                               receives_asylum_support: applicant.details.receives_asylum_support?)
          end
        end
        assessment.update!(assessment_result: summarized_result(assessment.eligibilities.map(&:assessment_result)))
      end

    private

      def populate_eligibility_records(assessment:, dependants:, partner_dependants:)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment:, client_dependants: dependants, partner_dependants:)
      end

      def summarized_result(results)
        Utilities::ResultSummarizer.call(results)
      end
    end
  end
end
