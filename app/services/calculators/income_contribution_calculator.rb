module Calculators
  class IncomeContributionCalculator
    class << self
      def call(income, submission_date)
        config = Threshold.value_for(:disposable_income_contribution_bands, at: submission_date)
        bands = config.fetch(:bands)
        band_name, band_value = bands.reverse_each.detect { |_name, value| income > value[:threshold] }
        if band_name == :band_zero
          0.0
        else
          value = contribution(band_value, income)
          if value < config[:minimum_contribution]
            0.0
          else
            value
          end
        end
      end

    private

      def contribution(band, income)
        (band[:base] + (income - band[:disregard]) * (band[:percentage] / 100.0)).round(2)
      end
    end
  end
end
