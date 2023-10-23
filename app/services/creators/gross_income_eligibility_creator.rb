module Creators
  class GrossIncomeEligibilityCreator
    class << self
      def call(dependants:, proceeding_types:, submission_date:, total_gross_income:, level_of_help:)
        proceeding_types.map do |proceeding_type|
          upper_threshold = upper_threshold(submission_date:, dependants:, proceeding_type:)
          lower_threshold = lower_threshold(level_of_help:, submission_date:)
          result = result_from_threshold(total_gross_income:, upper_threshold:)

          Eligibility::GrossIncome.new(
            proceeding_type:,
            upper_threshold:,
            lower_threshold:,
            assessment_result: result,
          ).freeze
        end
      end

      def assessment_results(dependants:, proceeding_types:, submission_date:, total_gross_income:)
        pairs = proceeding_types.map do |proceeding_type|
          upper_threshold = upper_threshold(submission_date:, dependants:, proceeding_type:)
          result = result_from_threshold(total_gross_income:, upper_threshold:)
          [proceeding_type, result]
        end
        pairs.to_h
      end

    private

      def result_from_threshold(total_gross_income:, upper_threshold:)
        total_gross_income < upper_threshold ? "eligible" : "ineligible"
      end

      def lower_threshold(level_of_help:, submission_date:)
        if level_of_help == "controlled"
          Threshold.value_for(:gross_income_lower_controlled, at: submission_date)
        else
          0.0
        end
      end

      def upper_threshold(dependants:, proceeding_type:, submission_date:)
        dependant_increase_starts_after = thresholds(submission_date)[:dependant_increase_starts_after]
        if proceeding_type.gross_income_upper_threshold == 999_999_999_999
          proceeding_type.gross_income_upper_threshold
        elsif dependant_increase_starts_after.present?
          proceeding_type.gross_income_upper_threshold +
            dependant_increase(countable_child_dependants: number_of_child_dependants(dependants) - dependant_increase_starts_after, submission_date:)
        else
          proceeding_type.gross_income_upper_threshold * (1 + (dependant_percentage_increase(dependants:, submission_date:) / 100.0))
        end
      end

      def dependant_percentage_increase(dependants:, submission_date:)
        under_14_count = dependants.count(&:under_14_years_old?)
        over_14_count = dependants.count - under_14_count

        under_14_count * thresholds(submission_date).fetch(:dependant_under_14_increase_percent) +
          over_14_count * thresholds(submission_date).fetch(:dependant_over_14_increase_percent)
      end

      def dependant_increase(countable_child_dependants:, submission_date:)
        if countable_child_dependants.positive?
          countable_child_dependants * dependant_step(submission_date)
        else
          0
        end
      end

      # We check 'child_relative' here is this is the important test (they could be >18 but still dependant)
      # rather than the 'over_16' test for childcare eligibility
      def number_of_child_dependants(dependants)
        dependants.count { |c| c.relationship == "child_relative" }
      end

      def dependant_step(submission_date)
        thresholds(submission_date).fetch(:dependant_step)
      end

      def thresholds(submission_date)
        Threshold.value_for(:gross_income, at: submission_date)
      end
    end
  end
end
