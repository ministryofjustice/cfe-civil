module Calculators
  # The functionality here is a mirror-image of the code in HousingBenefitCalculator, which knows to
  # ignore housing benefit (as its a disposable calculation) when housing_benefit_gross? is true (post MTR)
  # This is the gross income version, that knows to include it even though it is (arbitrarily) marked as 'exclude_from_gross_income'
  # in the StateBenefits table. This doesn't quite describe housing_benefit, as it has traditionally been *included* in disposable
  # (unlike all other benefits, which are ignored completely if exclude_from_gross_income is set true in the StateBenefit table)
  class StateBenefitsCalculator
    Benefits = Data.define(:state_benefits_regular, :state_benefits_bank)

    class << self
      def benefits(gross_income_summary:, submission_date:)
        Benefits.new state_benefits_regular: state_benefits_regular(gross_income_summary, submission_date),
                     state_benefits_bank: state_benefits_bank(gross_income_summary, submission_date)
      end

    private

      def state_benefits_regular(gross_income_summary, submission_date)
        transactions = if housing_benefit_gross?(submission_date)
                         gross_income_summary.regular_transactions.with_operation_and_category(:credit, :benefits) +
                           gross_income_summary.regular_transactions.with_operation_and_category(:credit, :housing_benefit)
                       else
                         gross_income_summary.regular_transactions.with_operation_and_category(:credit, :benefits)
                       end
        MonthlyRegularTransactionAmountCalculator.call(transactions)
      end

      def state_benefits_bank(gross_income_summary, submission_date)
        state_benefits = gross_income_summary.state_benefits.reject(&:exclude_from_gross_income)
        state_benefit_totals = state_benefits.sum { |sb| MonthlyEquivalentCalculator.call(collection: sb.state_benefit_payments) }
        if housing_benefit_gross?(submission_date)
          state_benefit_totals + MonthlyEquivalentCalculator.call(collection: gross_income_summary.housing_benefit_payments)
        else
          state_benefit_totals
        end
      end

      # are housing benefits part of gross income (post MTR) or disposable income (before)
      def housing_benefit_gross?(submission_date)
        Threshold.value_for(:housing_benefit_in_gross_income, at: submission_date).present?
      end
    end
  end
end
