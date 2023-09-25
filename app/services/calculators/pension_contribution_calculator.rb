module Calculators
  class PensionContributionCalculator
    class << self
      def pension_contribution_cap(total_gross_income:, submission_date:, pension_contributions:, calculator:)
        if thresholds(submission_date).present?
          pension_contribution_cap = (total_gross_income * pension_contribution_cap_pctg(submission_date)).round(2)
          monthly_pension_contribution = calculator.call(collection: pension_contributions)
          monthly_pension_contribution > pension_contribution_cap ? pension_contribution_cap : monthly_pension_contribution
        else
          0
        end
      end

    private

      def pension_contribution_cap_pctg(submission_date)
        thresholds(submission_date) / 100.0
      end

      def thresholds(submission_date)
        Threshold.value_for(:pension_contribution_cap, at: submission_date)
      end
    end
  end
end
