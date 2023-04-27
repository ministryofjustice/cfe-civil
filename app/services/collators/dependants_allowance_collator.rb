module Collators
  class DependantsAllowanceCollator
    Result = Data.define(:under_16, :over_16)

    class << self
      def call(dependants:, submission_date:)
        under_16s = dependants.select(&:under_16_years_old?)
        over_16s = dependants.reject(&:under_16_years_old?)
        Result.new over_16: allowance_sum(over_16s, submission_date),
                   under_16: allowance_sum(under_16s, submission_date)
      end

    private

      def allowance_sum(dependants, submission_date)
        dependants.sum { |dependant| Calculators::DependantAllowanceCalculator.call(dependant, submission_date) }
      end
    end
  end
end
