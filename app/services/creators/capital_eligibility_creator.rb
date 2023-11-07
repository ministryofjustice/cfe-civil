module Creators
  class CapitalEligibilityCreator
    class << self
      def call(proceeding_types:, level_of_help:, submission_date:, assessed_capital:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).map do |proceeding_type, threshold|
          Eligibility::Capital.new(
            proceeding_type:,
            upper_threshold: threshold.upper_threshold,
            lower_threshold: threshold.lower_threshold,
            assessment_result: assessed_result(assessed_capital:, lower_threshold: threshold.lower_threshold, upper_threshold: threshold.upper_threshold),
          )
        end
      end

      def assessment_results(proceeding_types:, level_of_help:, submission_date:, assessed_capital:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).transform_values do |threshold|
          assessed_result(assessed_capital:, lower_threshold: threshold.lower_threshold, upper_threshold: threshold.upper_threshold)
        end
      end

      def unassessed(proceeding_types:, level_of_help:, submission_date:)
        thresholds_for(proceeding_types:, submission_date:, level_of_help:).map do |proceeding_type, threshold|
          Eligibility::Capital.new(
            proceeding_type:,
            upper_threshold: threshold.upper_threshold,
            lower_threshold: threshold.lower_threshold,
            assessment_result: "pending",
          )
        end
      end

    private

      UpperLowerThreshold = Data.define :upper_threshold, :lower_threshold

      def thresholds_for(proceeding_types:, submission_date:, level_of_help:)
        proceeding_types.index_with do |proceeding_type|
          if level_of_help == "controlled"
            controlled_thresholds(proceeding_type:, submission_date:)
          else
            certificated_thresholds(proceeding_type:, submission_date:)
          end
        end
      end

      def controlled_thresholds(proceeding_type:, submission_date:)
        controlled_immigration_threshold = Threshold.value_for(:capital_immigration_first_tier_tribunal_controlled, at: submission_date)

        threshold = if controlled_immigration_threshold.present? && proceeding_type.ccms_code.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
                      controlled_immigration_threshold
                    else
                      proceeding_type.capital_upper_threshold
                    end
        UpperLowerThreshold.new(upper_threshold: threshold, lower_threshold: threshold)
      end

      def certificated_thresholds(proceeding_type:, submission_date:)
        immigration_threshold = Threshold.value_for(:capital_immigration_upper_tribunal_certificated, at: submission_date)
        if immigration_threshold.present? && proceeding_type.ccms_code.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
          UpperLowerThreshold.new(upper_threshold: immigration_threshold, lower_threshold: immigration_threshold)
        else
          asylum_threshold = Threshold.value_for(:capital_asylum_upper_tribunal_certificated, at: submission_date)
          if asylum_threshold.present? && proceeding_type.ccms_code.to_sym == CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE
            UpperLowerThreshold.new(upper_threshold: asylum_threshold, lower_threshold: asylum_threshold)
          else
            upper_threshold = proceeding_type.capital_upper_threshold
            lower_threshold = Threshold.value_for(:capital_lower_certificated, at: submission_date)
            UpperLowerThreshold.new(upper_threshold:, lower_threshold:)
          end
        end
      end

      def assessed_result(assessed_capital:, lower_threshold:, upper_threshold:)
        if assessed_capital <= lower_threshold
          :eligible
        elsif assessed_capital <= upper_threshold
          :contribution_required
        else
          :ineligible
        end
      end
    end
  end
end
