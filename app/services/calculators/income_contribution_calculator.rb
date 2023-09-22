module Calculators
  class IncomeContributionCalculator
    class << self
      def call(income, submission_date)
        bands = Threshold.value_for(:disposable_income_contribution_bands, at: submission_date)
        band_name, band_value = bands.reverse_each.detect { |_name, value| income > value[:threshold] }
        if band_name == :band_zero
          0.0
        else
          contribution band_value, income
        end
      end

    private

      def contribution(band, income)
        (band[:base] + (income - band[:disregard]) * (band[:percentage] / 100.0)).round(2)
      end
    end
  end
end
