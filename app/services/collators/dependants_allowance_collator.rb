module Collators
  class DependantsAllowanceCollator
    Result = Data.define(:under_16, :over_16)

    class << self
      def call(dependants:, submission_date:)
        dependants.each do |dependant|
          dependant.update!(dependant_allowance: Calculators::DependantAllowanceCalculator.call(dependant, submission_date))
        end
        under_16s = dependants.select(&:under_16_years_old?)
        over_16s = dependants.reject(&:under_16_years_old?)
        Result.new over_16: over_16s.sum(&:dependant_allowance),
                   under_16: under_16s.sum(&:dependant_allowance)
      end
    end
  end
end
