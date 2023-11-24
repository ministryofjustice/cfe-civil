module Creators
  class DisposableIncomeEligibilityCreator
    class << self
      def call(proceeding_types:, submission_date:, level_of_help:, total_disposable_income:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).map do |proceeding_type, threshold|
          Eligibility::DisposableIncome.new(proceeding_type:,
                                            upper_threshold: threshold.upper_threshold,
                                            lower_threshold: threshold.lower_threshold,
                                            assessment_result: assessment_result(lower_threshold: threshold.lower_threshold,
                                                                                 upper_threshold: threshold.upper_threshold,
                                                                                 total_disposable_income:,
                                                                                 submission_date:))
        end
      end

      def assessment_results(proceeding_types:, submission_date:, level_of_help:, total_disposable_income:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).transform_values do |threshold|
          assessment_result(lower_threshold: threshold.lower_threshold,
                            upper_threshold: threshold.upper_threshold,
                            total_disposable_income:,
                            submission_date:)
        end
      end

      def unassessed(proceeding_types:, level_of_help:, submission_date:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).map do |proceeding_type, threshold|
          Eligibility::DisposableIncome.new(proceeding_type:,
                                            upper_threshold: threshold.upper_threshold,
                                            lower_threshold: threshold.lower_threshold,
                                            assessment_result: "not_calculated")
        end
      end

    private

      UpperLowerThreshold = Data.define :upper_threshold, :lower_threshold

      def thresholds_for(proceeding_types:, submission_date:, level_of_help:)
        proceeding_types.index_with do |proceeding_type|
          threshold = immigration_and_asylum_certificated_threshold(submission_date)
          if threshold.present? && proceeding_type.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES)
            UpperLowerThreshold.new(upper_threshold: threshold, lower_threshold: threshold)
          else
            lower_threshold = lower_threshold(level_of_help:, submission_date:)
            upper_threshold = proceeding_type.disposable_income_upper_threshold
            UpperLowerThreshold.new(upper_threshold:, lower_threshold:)
          end
        end
      end

      def assessment_result(lower_threshold:, upper_threshold:, total_disposable_income:, submission_date:)
        if total_disposable_income <= lower_threshold
          "eligible"
        elsif total_disposable_income <= upper_threshold
          contribution = Calculators::IncomeContributionCalculator.call(total_disposable_income, submission_date)
          if contribution.zero?
            "eligible"
          else
            "contribution_required"
          end
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
