module Creators
  class GrossIncomeEligibilityCreator
    class << self
      def call(summary, dependants, proceeding_types, submission_date)
        proceeding_types.each { |proceeding_type| create_eligibility(summary:, submission_date:, dependants:, proceeding_type:) }
      end

  private

      def create_eligibility(summary:, dependants:, proceeding_type:, submission_date:)
        summary.eligibilities.create!(
          proceeding_type_code: proceeding_type.ccms_code,
          upper_threshold: upper_threshold(proceeding_type:, submission_date:, dependants:),
          assessment_result: "pending",
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
