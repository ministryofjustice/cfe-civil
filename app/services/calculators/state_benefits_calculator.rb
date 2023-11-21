module Calculators
  class StateBenefitsCalculator
    Benefits = Data.define(:state_benefits_regular, :state_benefits_bank)

    class << self
      def benefits(regular_transactions:, submission_date:, state_benefits:)
        Benefits.new state_benefits_regular: state_benefits_regular(regular_transactions, submission_date),
                     state_benefits_bank: state_benefits_bank(submission_date:, state_benefits:)
      end

      # Housing benefit - in gross income calc, should housing benefit is considered a source of income?
      # - False pre-MTR
      # - True post-MTR
      # Note: In the StateBenefits table/API, housing benefit has exclude_from_gross_income=True, which for other benefits means:
      #   "Disregarded payment" - exclude from gross income and disposable income
      # and is true for housing benefit before MTR. But post-MTR, Housing Benefit is included in gross income, so that will need fixing.
      def housing_benefit_included_in_gross_income?(submission_date)
        Threshold.value_for(:housing_benefit_in_gross_income, at: submission_date).present?
      end

    private

      def state_benefits_regular(regular_transactions, submission_date)
        transactions = if housing_benefit_included_in_gross_income?(submission_date)
                         regular_transactions.with_operation_and_category(:credit, :benefits) +
                           regular_transactions.with_operation_and_category(:credit, :housing_benefit)
                       else
                         regular_transactions.with_operation_and_category(:credit, :benefits)
                       end
        MonthlyRegularTransactionAmountCalculator.call(transactions)
      end

      def state_benefits_bank(submission_date:, state_benefits:)
        benefits = state_benefits.reject(&:exclude_from_gross_income)
        state_benefit_totals = benefits.sum { |sb| MonthlyEquivalentCalculator.call(collection: sb.state_benefit_payments) }
        if housing_benefit_included_in_gross_income?(submission_date)
          state_benefit_totals + MonthlyEquivalentCalculator.call(collection: state_benefits.select(&:housing_benefit?).flat_map(&:state_benefit_payments))
        else
          state_benefit_totals
        end
      end
    end
  end
end
