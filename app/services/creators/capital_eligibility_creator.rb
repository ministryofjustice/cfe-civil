module Creators
  class CapitalEligibilityCreator
    class << self
      def call(proceeding_types:, level_of_help:, submission_date:, assessed_capital:)
        proceeding_types.map { |proceeding_type| create_eligibility(proceeding_type:, level_of_help:, submission_date:) }.map do |e|
          Eligibility::Capital.new(
            proceeding_type: e.proceeding_type,
            upper_threshold: e.upper_threshold,
            lower_threshold: e.lower_threshold,
            assessment_result: assessed_result(assessed_capital:, lower_threshold: e.lower_threshold, upper_threshold: e.upper_threshold),
          )
        end
      end

      def unassessed(proceeding_types:, level_of_help:, submission_date:)
        proceeding_types.map { |proceeding_type| create_eligibility(proceeding_type:, level_of_help:, submission_date:) }.map do |e|
          Eligibility::Capital.new(
            proceeding_type: e.proceeding_type,
            upper_threshold: e.upper_threshold,
            lower_threshold: e.lower_threshold,
            assessment_result: "pending",
          )
        end
      end

    private

      CapitalEligibility = Data.define(:proceeding_type, :lower_threshold, :upper_threshold)

      def create_eligibility(proceeding_type:, level_of_help:, submission_date:)
        if level_of_help == "controlled"
          threshold = controlled_threshold(proceeding_type, submission_date)
          CapitalEligibility.new(
            proceeding_type:,
            upper_threshold: threshold,
            lower_threshold: threshold,
          )
        elsif proceeding_type.ccms_code.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
          threshold = immigration_threshold(submission_date)
          CapitalEligibility.new(
            proceeding_type:,
            upper_threshold: threshold,
            lower_threshold: threshold,
          )
        elsif proceeding_type.ccms_code.to_sym == CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE
          threshold = asylum_threshold(submission_date)
          CapitalEligibility.new(
            proceeding_type:,
            upper_threshold: threshold,
            lower_threshold: threshold,
          )
        else
          upper_threshold = proceeding_type.capital_upper_threshold
          lower_threshold = lower_threshold(submission_date)
          CapitalEligibility.new(
            proceeding_type:,
            upper_threshold:,
            lower_threshold:,
          )
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

      def immigration_threshold(submission_date)
        Threshold.value_for(:capital_immigration_upper_tribunal_certificated, at: submission_date)
      end

      def asylum_threshold(submission_date)
        Threshold.value_for(:capital_asylum_upper_tribunal_certificated, at: submission_date)
      end

      def controlled_threshold(ptc, submission_date)
        if ptc.ccms_code.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
          Threshold.value_for(:capital_immigration_first_tier_tribunal_controlled, at: submission_date)
        else
          ptc.capital_upper_threshold
        end
      end

      def lower_threshold(submission_date)
        Threshold.value_for(:capital_lower_certificated, at: submission_date)
      end
    end
  end
end
