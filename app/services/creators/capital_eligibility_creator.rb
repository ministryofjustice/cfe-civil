module Creators
  class CapitalEligibilityCreator
    class << self
      def call(proceeding_types:, level_of_help:, submission_date:, assessed_capital:)
        proceeding_types.map do |proceeding_type|
          threshold = thresholds_for(proceeding_type:, submission_date:, level_of_help:)

          Eligibility::Capital.new(
            proceeding_type:,
            upper_threshold: threshold.upper_threshold,
            lower_threshold: threshold.lower_threshold,
            assessment_result: assessed_result(assessed_capital:, threshold:),
          )
        end
      end

      def assessment_results(proceeding_types:, level_of_help:, submission_date:, assessed_capital:)
        proceeding_types.index_with do |proceeding_type|
          assessed_result(assessed_capital:, threshold: thresholds_for(proceeding_type:, submission_date:, level_of_help:))
        end
      end

      class DummyProceedingType
        def initialize(submission_date)
          @submission_date = submission_date
        end

        def immigration_case?
          false
        end

        def asylum_case?
          false
        end

        def capital_upper_threshold
          Threshold.value_for(:capital_upper, at: @submission_date)
        end
      end

      def lower_capital_threshold(proceeding_types:, level_of_help:, submission_date:)
        if proceeding_types.any?
          proceeding_types.map { |pt| thresholds_for(proceeding_type: pt, level_of_help:, submission_date:) }.map(&:lower_threshold).min
        else
          thresholds_for(proceeding_type: DummyProceedingType.new(submission_date), level_of_help:, submission_date:).lower_threshold
        end
      end

    private

      UpperLowerThreshold = Data.define :upper_threshold, :lower_threshold

      def thresholds_for(proceeding_type:, submission_date:, level_of_help:)
        if level_of_help == "controlled"
          controlled_thresholds(proceeding_type:, submission_date:)
        else
          certificated_thresholds(proceeding_type:, submission_date:)
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
        if immigration_threshold.present? && proceeding_type.immigration_case?
          UpperLowerThreshold.new(upper_threshold: immigration_threshold, lower_threshold: immigration_threshold)
        else
          asylum_threshold = Threshold.value_for(:capital_asylum_upper_tribunal_certificated, at: submission_date)
          if asylum_threshold.present? && proceeding_type.asylum_case?
            UpperLowerThreshold.new(upper_threshold: asylum_threshold, lower_threshold: asylum_threshold)
          else
            upper_threshold = proceeding_type.capital_upper_threshold
            lower_threshold = Threshold.value_for(:capital_lower_certificated, at: submission_date)
            UpperLowerThreshold.new(upper_threshold:, lower_threshold:)
          end
        end
      end

      def assessed_result(assessed_capital:, threshold:)
        if assessed_capital <= threshold.lower_threshold
          :eligible
        elsif assessed_capital <= threshold.upper_threshold
          :contribution_required
        else
          :ineligible
        end
      end
    end
  end
end
