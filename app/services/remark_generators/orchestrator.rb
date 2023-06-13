module RemarkGenerators
  class Orchestrator
    class << self
      def call(assessment:, employments:, disposable_income_summary:, gross_income_summary:, capital_summary:, assessed_capital:, lower_capital_threshold:)
        my_remarks = assessment.remarks
        remarks(assessed_capital:, employments:, disposable_income_summary:,
                lower_capital_threshold:,
                other_income_sources: gross_income_summary.other_income_sources,
                state_benefits: gross_income_summary.state_benefits, capital_summary:).each do |remark|
          my_remarks.add(remark.type, remark.issue, remark.ids)
        end
        assessment.update!(remarks: my_remarks)
      end

    private

      def remarks(disposable_income_summary:, employments:, state_benefits:, other_income_sources:, capital_summary:,
                  assessed_capital:, lower_capital_threshold:)
        check_amount_variations(state_benefits:,
                                other_income_sources:,
                                disposable_income_summary:) +
          check_frequencies(employments:,
                            other_income_sources:,
                            state_benefits:,
                            disposable_income_summary:) +
          check_residual_balances(capital_summary, assessed_capital, lower_capital_threshold) +
          check_flags(state_benefits, disposable_income_summary)
      end

      def check_amount_variations(state_benefits:, other_income_sources:, disposable_income_summary:)
        check_state_benefit_variations(state_benefits, disposable_income_summary) +
          check_other_income_variations(other_income_sources, disposable_income_summary) +
          check_outgoings_variation(disposable_income_summary)
      end

      def check_state_benefit_variations(state_benefits, disposable_income_summary)
        state_benefits.map { |sb| AmountVariationChecker.call(disposable_income_summary, sb.state_benefit_payments) }.compact
      end

      def check_other_income_variations(other_income_sources, disposable_income_summary)
        other_income_sources.map { |oi| AmountVariationChecker.call(disposable_income_summary, oi.other_income_payments) }.compact
      end

      def check_outgoings_variation(disposable_income_summary)
        disposable_income_summary.outgoings.group_by(&:type).values.flat_map { |collection| AmountVariationChecker.call(disposable_income_summary, collection) }.compact
      end

      def check_frequencies(employments:, state_benefits:, disposable_income_summary:, other_income_sources:)
        state_benefits.map { |sb| FrequencyChecker.call(disposable_income_summary, sb.state_benefit_payments) }.compact +
          other_income_sources.map { |oi| FrequencyChecker.call(disposable_income_summary, oi.other_income_payments) }.compact +
          disposable_income_summary.outgoings.group_by(&:type).values.flat_map { |collection| FrequencyChecker.call(disposable_income_summary, collection) }.compact +
          employments.map { |job| FrequencyChecker.call(disposable_income_summary, job.employment_payments, :date) }.compact
      end

      def check_residual_balances(capital_summary, assessed_capital, lower_capital_threshold)
        [ResidualBalanceChecker.call(capital_summary, assessed_capital, lower_capital_threshold)].compact
      end

      def check_flags(state_benefits, disposable_income_summary)
        state_benefits.map { |sb| MultiBenefitChecker.call(disposable_income_summary, sb.state_benefit_payments) }.compact
      end
    end
  end
end
