module RemarkGenerators
  class Orchestrator
    class << self
      def call(employments:, outgoings:, child_care_bank:, gross_income_summary:,
               assessed_capital:, lower_capital_threshold:, liquid_capital_items:)
        check_amount_variations(state_benefits: gross_income_summary.state_benefits,
                                other_income_sources: gross_income_summary.other_income_sources,
                                outgoings:,
                                child_care_bank:) +
          check_frequencies(employments:,
                            other_income_sources: gross_income_summary.other_income_sources,
                            state_benefits: gross_income_summary.state_benefits,
                            child_care_bank:,
                            outgoings:) +
          check_residual_balances(liquid_capital_items, assessed_capital, lower_capital_threshold) +
          check_flags(gross_income_summary.state_benefits)
      end

    private

      def check_amount_variations(state_benefits:, other_income_sources:, outgoings:, child_care_bank:)
        check_state_benefit_variations(state_benefits:, child_care_bank:) +
          check_other_income_variations(other_income_sources:, child_care_bank:) +
          check_outgoings_variation(outgoings:, child_care_bank:)
      end

      def check_state_benefit_variations(state_benefits:, child_care_bank:)
        state_benefits.map { |sb| AmountVariationChecker.call(collection: sb.state_benefit_payments, child_care_bank:) }.compact
      end

      def check_other_income_variations(other_income_sources:, child_care_bank:)
        other_income_sources.map { |oi| AmountVariationChecker.call(collection: oi.other_income_payments, child_care_bank:) }.compact
      end

      def check_outgoings_variation(outgoings:, child_care_bank:)
        outgoings.group_by(&:type).values.flat_map { |collection| AmountVariationChecker.call(collection:, child_care_bank:) }.compact
      end

      def check_frequencies(employments:, state_benefits:, outgoings:, other_income_sources:, child_care_bank:)
        state_benefits.map { |sb| FrequencyChecker.call(collection: sb.state_benefit_payments, child_care_bank:) }.compact +
          other_income_sources.map { |oi| FrequencyChecker.call(collection: oi.other_income_payments, child_care_bank:) }.compact +
          outgoings.group_by(&:type).values.flat_map { |collection| FrequencyChecker.call(collection:, child_care_bank:) }.compact +
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
