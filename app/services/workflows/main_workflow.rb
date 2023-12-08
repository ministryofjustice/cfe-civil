module Workflows
  class MainWorkflow
    Result = Data.define(:calculation_output, :remarks, :assessment_result)

    class << self
      def with_partner(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        call(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
      end

      def without_partner(applicant:, proceeding_types:, level_of_help:, submission_date:)
        call(applicant:, partner: nil, proceeding_types:, level_of_help:, submission_date:)
      end

    private

      def call(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        if applicant.details.receives_qualifying_benefit?
          calculation_output = if partner.present?
                                 PassportedWorkflow.with_partner(capitals_data: applicant.capitals_data,
                                                                 partner_capitals_data: partner.capitals_data,
                                                                 submission_date:,
                                                                 level_of_help:,
                                                                 date_of_birth: applicant.details.date_of_birth,
                                                                 partner_date_of_birth: partner.details.date_of_birth)
                               else
                                 PassportedWorkflow.without_partner(capitals_data: applicant.capitals_data,
                                                                    submission_date:,
                                                                    level_of_help:,
                                                                    date_of_birth: applicant.details.date_of_birth)
                               end
          Result.new calculation_output:, remarks: { client: [], partner: [] }, assessment_result: calculation_output.capital_subtotals.summarized_assessment_result(proceeding_types)
        elsif partner.present?
          NonPassportedWorkflow.with_partner(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        else
          NonPassportedWorkflow.without_partner(applicant:, proceeding_types:, level_of_help:, submission_date:)
        end
      end
    end
  end
end
