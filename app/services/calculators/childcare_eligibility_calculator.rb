module Calculators
  class ChildcareEligibilityCalculator
    class << self
      def call(applicants:, dependants:, submission_date:)
        at_least_one_child_dependant?(dependants:, submission_date:) && all_applicants_are_employed_or_students?(applicants)
      end

    private

      # The guidance says that it would only be reasonable to claim childcare
      # for a child 15 or under (which is interpreted as whole years, so < 16)
      def at_least_one_child_dependant?(dependants:, submission_date:)
        dependants.any? do |dependant|
          submission_date.before?(dependant.becomes_16_on)
        end
      end

      def all_applicants_are_employed_or_students?(applicants)
        applicants.all? { _1.employed? || _1.is_student? }
      end
    end
  end
end
