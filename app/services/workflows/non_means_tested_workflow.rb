# frozen_string_literal: true

module Workflows
  class NonMeansTestedWorkflow
    class << self
      def non_means_tested?(proceeding_type_codes:, receives_asylum_support:, submission_date:, level_of_help:, controlled_legal_representation:, not_aggregated_no_income_low_capital:, applicant_under_18_years_old:)
        # skip proceeding types check if applicant receives asylum support after MTR go-live date
        if level_of_help == Assessment::CONTROLLED && controlled_legal_representation && applicant_under_18_years_old
          true
        elsif level_of_help == Assessment::CONTROLLED && not_aggregated_no_income_low_capital && applicant_under_18_years_old
          true
        elsif level_of_help == Assessment::CERTIFICATED && applicant_under_18_years_old
          true
        elsif asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
          receives_asylum_support
        else
          proceeding_type_codes.map(&:to_sym).all? { _1.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } && receives_asylum_support
        end
      end

      def blank_calculation_result(proceeding_types:, level_of_help:, submission_date:)
        calculation_output = CalculationOutput.new(
          level_of_help:, submission_date:,
          gross_income_subtotals: GrossIncome::Unassessed.new(level_of_help:, submission_date:),
          disposable_income_subtotals: DisposableIncome::Unassessed.new(level_of_help:, submission_date:),
          capital_subtotals: Capital::Unassessed.new(submission_date:, level_of_help:)
        )
        workflow = Workflows::MainWorkflow::Result.new calculation_output:, remarks: [], assessment_result: :eligible

        er = EligibilityResults::BlankEligibilityResult.new(proceeding_types:, level_of_help:, submission_date:)
        ResultAndEligibility.new workflow_result: workflow, eligibility_result: er
      end

    private

      def asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
        !!Threshold.value_for(:asylum_support_is_non_means_tested_for_all_matter_types, at: submission_date)
      end
    end
  end
end
