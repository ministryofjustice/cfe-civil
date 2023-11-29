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
        if non_means_tested?(proceeding_type_codes: proceeding_types.pluck(:ccms_code),
                             receives_asylum_support: applicant.details.receives_asylum_support, submission_date:)
          blank_calculation_result(submission_date:,
                                   level_of_help:)
        elsif applicant.details.receives_qualifying_benefit?
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
          Result.new calculation_output:, remarks: [], assessment_result: calculation_output.capital_subtotals.summarized_assessment_result(proceeding_types)
        elsif partner.present?
          NonPassportedWorkflow.with_partner(applicant:, partner:, proceeding_types:, level_of_help:, submission_date:)
        else
          NonPassportedWorkflow.without_partner(applicant:, proceeding_types:, level_of_help:, submission_date:)
        end
      end

      def non_means_tested?(proceeding_type_codes:, receives_asylum_support:, submission_date:)
        # skip proceeding types check if applicant receives asylum support after MTR go-live date
        if asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
          receives_asylum_support
        else
          proceeding_type_codes.map(&:to_sym).all? { _1.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } && receives_asylum_support
        end
      end

      def asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
        !!Threshold.value_for(:asylum_support_is_non_means_tested_for_all_matter_types, at: submission_date)
      end

      def blank_calculation_result(level_of_help:, submission_date:)
        calculation_output = CalculationOutput.new(level_of_help:, submission_date:,
                                                   gross_income_subtotals: GrossIncome::Unassessed.new(level_of_help:, submission_date:),
                                                   disposable_income_subtotals: DisposableIncome::Unassessed.new(level_of_help:, submission_date:),
                                                   capital_subtotals: Capital::Unassessed.new(submission_date:, level_of_help:))
        Result.new calculation_output:, remarks: [], assessment_result: :eligible
      end
    end
  end
end
