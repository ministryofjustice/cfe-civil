module Decorators
  module V6
    class ApplicantDisposableIncomeResultDecorator < DisposableIncomeResultDecorator
      def initialize(employment_income_subtotals, disposable_income_subtotals:, income_contribution:,
                     combined_total_disposable_income:,
                     combined_total_outgoings_and_allowances:, eligibilities:)
        super(employment_income_subtotals, disposable_income_subtotals:)
        @combined_total_disposable_income = combined_total_disposable_income
        @combined_total_outgoings_and_allowances = combined_total_outgoings_and_allowances
        @income_contribution = income_contribution
        @eligibilities = eligibilities
      end

      def as_json
        super.merge(proceeding_types:,
                    combined_total_disposable_income:,
                    combined_total_outgoings_and_allowances:,
                    partner_allowance:,
                    lone_parent_allowance: @disposable_income_subtotals.lone_parent_allowance,
                    income_contribution: @income_contribution)
      end

    private

      def proceeding_types
        ProceedingTypesResultDecorator.new(@eligibilities).as_json
      end

      def partner_allowance
        @disposable_income_subtotals.partner_allowance
      end

      def combined_total_disposable_income
        @combined_total_disposable_income.to_f
      end

      def combined_total_outgoings_and_allowances
        @combined_total_outgoings_and_allowances.to_f
      end
    end
  end
end
