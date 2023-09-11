module Creators
  class DisposableIncomeEligibilityCreator
    class << self
      def call(proceeding_types:, submission_date:, level_of_help:, total_disposable_income:)
        proceeding_types.map { |proceeding_type| create_assessed(proceeding_type:, submission_date:, level_of_help:, total_disposable_income:) }.map(&:freeze)
      end

      def unassessed(proceeding_types:, level_of_help:, submission_date:)
        proceeding_types.map { |proceeding_type| create_unassessed(proceeding_type:, level_of_help:, submission_date:) }.map(&:freeze)
      end

    private

      def create_assessed(proceeding_type:, submission_date:, level_of_help:, total_disposable_income:)
        create_eligibility(proceeding_type:, submission_date:, level_of_help:).tap do |e|
          e.assessment_result = assessment_result(lower_threshold: e.lower_threshold, upper_threshold: e.upper_threshold, total_disposable_income:)
        end
      end

      def create_unassessed(proceeding_type:, submission_date:, level_of_help:)
        create_eligibility(proceeding_type:, submission_date:, level_of_help:).tap do |e|
          e.assessment_result = "pending"
        end
      end

      def create_eligibility(proceeding_type:, submission_date:, level_of_help:)
        if proceeding_type.ccms_code.to_sym.in? CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES
          threshold = immigration_and_asylum_certificated_threshold(submission_date)
          Eligibility::DisposableIncome.new(
            proceeding_type_code: proceeding_type.ccms_code,
            upper_threshold: threshold,
            lower_threshold: threshold,
          )
        else
          lower_threshold = lower_threshold(level_of_help:, submission_date:)
          upper_threshold = proceeding_type.disposable_income_upper_threshold
          Eligibility::DisposableIncome.new(
            proceeding_type_code: proceeding_type.ccms_code,
            upper_threshold:,
            lower_threshold:,
          )
        end
      end

      def assessment_result(lower_threshold:, upper_threshold:, total_disposable_income:)
        if total_disposable_income <= lower_threshold
          "eligible"
        elsif total_disposable_income <= upper_threshold
          "contribution_required"
        else
          "ineligible"
        end
      end

      def immigration_and_asylum_certificated_threshold(submission_date)
        Threshold.value_for(:disposable_income_certificated_immigration_asylum_upper_tribunal, at: submission_date)
      end

      def lower_threshold(level_of_help:, submission_date:)
        if level_of_help == "controlled"
          Threshold.value_for(:disposable_income_lower_controlled, at: submission_date)
        else
          Threshold.value_for(:disposable_income_lower_certificated, at: submission_date)
        end
      end
    end
  end
end
