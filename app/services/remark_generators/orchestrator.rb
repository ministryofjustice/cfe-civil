module RemarkGenerators
  class Orchestrator
    class << self
      def call(employments:, outgoings:, child_care_bank:, other_income_payments:, cash_transactions:, regular_transactions:,
               assessed_capital:, lower_capital_threshold:, liquid_capital_items:, state_benefits:, submission_date:)

        remarks_data = []
        remarks_data << check_amount_variations(state_benefits:,
                                                other_income_payments:,
                                                outgoings:,
                                                child_care_bank:)
        remarks_data << check_frequencies(employments:,
                                          other_income_payments:,
                                          state_benefits:,
                                          child_care_bank:,
                                          outgoings:)
        remarks_data << check_residual_balances(liquid_capital_items, assessed_capital, lower_capital_threshold)
        remarks_data << check_flags(state_benefits)
        if priority_debt_repayment_enabled?(submission_date)
          remarks_data << check_payments(cash_transactions:, regular_transactions:, outgoings:)
        end
        remarks_data.flatten
      end

    private

      def check_payments(cash_transactions:, regular_transactions:, outgoings:)
        PaymentChecker.call(cash_transactions:, regular_transactions:, outgoings:)
      end

      def priority_debt_repayment_enabled?(submission_date)
        !!Threshold.value_for(:priority_debt_repayment_enabled, at: submission_date)
      end

      def check_amount_variations(state_benefits:, other_income_payments:, outgoings:, child_care_bank:)
        check_state_benefit_variations(state_benefits:, child_care_bank:) +
          check_other_income_variations(other_income_payments:, child_care_bank:) +
          check_outgoings_variation(outgoings:, child_care_bank:)
      end

      def check_state_benefit_variations(state_benefits:, child_care_bank:)
        state_benefits.map { |sb| AmountVariationChecker.call(collection: sb.state_benefit_payments, child_care_bank:) }.compact
      end

      def check_other_income_variations(other_income_payments:, child_care_bank:)
        other_income_payments.group_by(&:category).values.flat_map { |collection| AmountVariationChecker.call(collection:, child_care_bank:) }.compact
      end

      def check_outgoings_variation(outgoings:, child_care_bank:)
        outgoings.group_by(&:class).values.flat_map { |collection| AmountVariationChecker.call(collection:, child_care_bank:) }.compact
      end

      def check_frequencies(employments:, state_benefits:, outgoings:, other_income_payments:, child_care_bank:)
        state_benefits.map { |sb| FrequencyChecker.call(collection: sb.state_benefit_payments, child_care_bank:) }.compact +
          other_income_payments.group_by(&:category).values.flat_map { |collection| FrequencyChecker.call(collection:, child_care_bank:) }.compact +
          outgoings.group_by(&:class).values.flat_map { |collection| FrequencyChecker.call(collection:, child_care_bank:) }.compact +
          employments.map { |job| FrequencyChecker.call(collection: job.employment_payments, date_attribute: :date, child_care_bank:) }.compact
      end

      def check_residual_balances(liquid_capital_items, assessed_capital, lower_capital_threshold)
        [ResidualBalanceChecker.call(liquid_capital_items, assessed_capital, lower_capital_threshold)].compact
      end

      def check_flags(state_benefits)
        state_benefits.map { |sb| MultiBenefitChecker.call(sb.state_benefit_payments) }.compact
      end
    end
  end
end
