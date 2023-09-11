module Creators
  class GrossIncomeEligibilityCreator
    class << self
      def call(dependants:, proceeding_types:, submission_date:, total_gross_income:)
        proceeding_types.map { |proceeding_type| create_eligibility(submission_date:, dependants:, proceeding_type:, total_gross_income:) }.map(&:freeze)
      end

    private

      def create_eligibility(dependants:, proceeding_type:, submission_date:, total_gross_income:)
        upper_threshold = upper_threshold(proceeding_type:, submission_date:, dependants:)
        Eligibility::GrossIncome.new(
          proceeding_type_code: proceeding_type.ccms_code,
          upper_threshold:,
          assessment_result: (total_gross_income < upper_threshold ? "eligible" : "ineligible"),
        )
      end

      def upper_threshold(proceeding_type:, submission_date:, dependants:)
        base_threshold = proceeding_type.gross_income_upper_threshold
        return base_threshold if base_threshold == 999_999_999_999

        base_threshold + dependant_increase(dependants, submission_date)
      end

      def dependant_increase(dependants, submission_date)
        return 0 unless number_of_child_dependants(dependants) > dependant_increase_starts_after(submission_date)

        (number_of_child_dependants(dependants) - dependant_increase_starts_after(submission_date)) * dependant_step(submission_date)
      end

      # We check 'child_relative' here is this is the important test (they could be >18 but still dependant)
      # rather than the 'over_16' test for childcare eligibility
      def number_of_child_dependants(dependants)
        dependants.count { |c| c.relationship == "child_relative" }
      end

      def dependant_increase_starts_after(submission_date)
        Threshold.value_for(:dependant_increase_starts_after, at: submission_date)
      end

      def dependant_step(submission_date)
        Threshold.value_for(:dependant_step, at: submission_date)
      end
    end
  end
end
