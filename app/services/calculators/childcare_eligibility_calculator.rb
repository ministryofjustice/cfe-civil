module Calculators
  class ChildcareEligibilityCalculator
    class << self
      def call(applicant_incomes:, dependants:, submission_date:)
        at_least_one_child_dependant?(dependants:, submission_date:) && all_applicants_are_in_work_or_students?(applicant_incomes)
      end

    private

      # The guidance says that it would only be reasonable to claim childcare
      # for a child 15 or under (which is interpreted as whole years, so < 16)
      def at_least_one_child_dependant?(dependants:, submission_date:)
        dependants.any? do |dependant|
          submission_date.before?(dependant.becomes_16_on)
        end
      end

      def all_applicants_are_in_work_or_students?(applicant_incomes)
        applicant_incomes.all? { _1.employment_income_subtotals.in_work? || _1.is_student? }
      end
    end
  end
end
