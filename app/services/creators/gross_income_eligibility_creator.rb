module Creators
  class GrossIncomeEligibilityCreator
    class << self
      # The 'lower threshold' here has a different meaning from the other 2 (which are contribution thresholds)
      # This one allows controlled work to skip the capital and disposable tests if the gross is below a specific figure
      def call(dependants:, proceeding_types:, submission_date:, total_gross_income:, level_of_help:)
        upper_thresholds(dependants:, proceeding_types:, submission_date:).map do |proceeding_type, upper_threshold|
          Eligibility::GrossIncome.new(
            proceeding_type:,
            upper_threshold:,
            lower_threshold: lower_threshold(submission_date:, level_of_help:),
            assessment_result: result_from_threshold(total_gross_income:, upper_threshold:),
          ).freeze
        end
      end

      def assessment_results(dependants:, proceeding_types:, submission_date:, total_gross_income:)
        upper_thresholds(dependants:, proceeding_types:, submission_date:).transform_values do |upper_threshold|
          result_from_threshold(total_gross_income:, upper_threshold:)
        end
      end

      def lower_threshold(level_of_help:, submission_date:)
        if level_of_help == "controlled"
          Threshold.value_for(:gross_income_lower_controlled, at: submission_date) || 0.0
        else
          0.0
        end
      end

    private

      def upper_thresholds(dependants:, proceeding_types:, submission_date:)
        proceeding_types.index_with { upper_threshold(submission_date:, dependants:, proceeding_type: _1) }
      end

      # There is no 'lower threshold' for gross income calculations -
      # it doesn't make sense to calculate a contribution based on gross anyway
      def result_from_threshold(total_gross_income:, upper_threshold:)
        total_gross_income < upper_threshold ? "eligible" : "ineligible"
      end

      def upper_threshold(dependants:, proceeding_type:, submission_date:)
        dependant_increase_starts_after = thresholds(submission_date)[:dependant_increase_starts_after]
        if proceeding_type.gross_income_upper_threshold == 999_999_999_999
          proceeding_type.gross_income_upper_threshold
        else
          non_earning_dependants = dependants.select { _1.monthly_income < Threshold.value_for(:dependant_allowances, at: submission_date).fetch(:child_16_and_over) }
          if dependant_increase_starts_after.present?
            proceeding_type.gross_income_upper_threshold +
              dependant_increase(countable_child_dependants: number_of_child_dependants(non_earning_dependants) - dependant_increase_starts_after, submission_date:)
          else
            proceeding_type.gross_income_upper_threshold * (1 + (dependant_percentage_increase(dependants: non_earning_dependants, submission_date:) / 100.0))
          end
        end
      end

      def dependant_percentage_increase(dependants:, submission_date:)
        under_14s, over_14s = dependants.partition(&:under_14_years_old?)

        under_14s.size * thresholds(submission_date).fetch(:dependant_under_14_increase_percent) +
          over_14s.size * thresholds(submission_date).fetch(:dependant_over_14_increase_percent)
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
        dependants.count(&:child_relative?)
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
