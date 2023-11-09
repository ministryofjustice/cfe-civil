# frozen_string_literal: true

module Calculators
  class LoneParentAllowanceCalculator
    class << self
      def call(dependants:, submission_date:)
        if dependants.count(&:child_relative?).positive?
          lone_parent_allowance(submission_date)
        else
          0
        end
      end

    private

      def lone_parent_allowance(submission_date)
        lpa_section = Threshold.value_for(:lone_parent_allowance, at: submission_date)
        if lpa_section
          dependant_allowances = Threshold.value_for(:dependant_allowances, at: submission_date)
          (dependant_allowances[:adult] * (lpa_section[:percentage_of_adult_dependent_allowance] / 100.0)).round(2)
        else
          0
        end
      end
    end
  end
end
