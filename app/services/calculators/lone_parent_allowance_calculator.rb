# frozen_string_literal: true

module Calculators
  class LoneParentAllowanceCalculator
    class << self
      def call(dependants:, submission_date:)
        if dependants.count(&:child_dependant?).positive?
          lone_parent_allowance(submission_date)
        else
          0
        end
      end

    private

      def lone_parent_allowance(submission_date)
        Threshold.value_for(:lone_parent_allowance, at: submission_date) || 0
      end
    end
  end
end
