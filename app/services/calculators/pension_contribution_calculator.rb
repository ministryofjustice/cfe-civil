module Calculators
  class PensionContributionCalculator
    class << self
      def pension_contribution_cap(total_gross_income:, submission_date:)
        if thresholds(submission_date).present?
          (total_gross_income * pension_contribution_cap_pctg(submission_date)).round(2)
        else
          0
        end
      end

    private

      def pension_contribution_cap_pctg(submission_date)
        Threshold.value_for(:pension_contribution_cap, at: submission_date) / 100.0
      end

      def thresholds(submission_date)
        Threshold.value_for(:pension_contribution_cap, at: submission_date)
      end
    end
  end
end
